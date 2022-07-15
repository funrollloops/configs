#include <dirent.h>
#include <stdio.h>
#include <string.h>
#include <sys/types.h>

#include <fstream>
#include <iostream>
#include <map>
#include <sstream>
#include <string>
#include <string_view>
#include <vector>

using namespace std::literals;

std::string read_contents(const std::string& path) {
  std::ifstream f(path);
  std::stringstream buf;
  buf << f.rdbuf();
  if (!f.good()) {
    std::cerr << "failed to write to " << path << ": " << strerror(errno)
              << std::endl;
    exit(2);
  }
  return buf.str();
}

void set_contents(const std::string& path, const std::string& contents) {
  std::ofstream f(path);
  f << contents;
  if (!f.good()) {
    std::cerr << "failed to write to " << path << ": " << strerror(errno)
              << std::endl;
    exit(2);
  }
  f.close();
}

const std::vector<std::string>& list_cpus() {
  static const std::vector<std::string> kCPUs = [&] {
    const std::string kCPUDir = "/sys/devices/system/cpu/";
    DIR* dp = opendir(kCPUDir.c_str());
    if (dp == NULL) {
      perror("Couldn't open the directory");
      exit(-1);
    }
    std::vector<std::string> result;
    while (dirent* ep = readdir(dp)) {
      std::string filename = ep->d_name;
      if (!isdigit(filename.back()) || filename.substr(0, 3) != "cpu") continue;
      result.push_back(kCPUDir + "/" + std::move(filename) + "/cpufreq/");
    }
    closedir(dp);
    return result;
  }();
  return kCPUs;
}

void summarize(const std::string& filename) {
  std::map<std::string, int> counts;
  for (const std::string& cpu : list_cpus()) {
    std::string value = read_contents(cpu + filename);
    while (!value.empty() && isspace(value.back())) value.pop_back();
    if (value.empty()) continue;
    if (isdigit(value[0])) {
      char buf[30];
      sprintf(buf, "%.1fG", std::atoi(value.c_str()) / 1e6);
      counts[buf]++;
    } else {
      counts[value]++;
    }
  }
  for (auto& [value, count] : counts) {
    std::cout << " ";
    if (count > 1) std::cout << count << "×";
    std::cout << value;
  }
}

void print_info() {
  std::cout << "governors:";
  summarize("scaling_governor");
  std::cout << "\nscaling min, max:";
  summarize("scaling_min_freq");
  std::cout << ",";
  summarize("scaling_max_freq");
  std::cout << "\ncpu min, max:";
  summarize("cpuinfo_min_freq");
  std::cout << ",";
  summarize("cpuinfo_max_freq");
  std::cout << "\ncurrent freq:";
  summarize("scaling_cur_freq");
  std::cout << std::endl;
}

void set_cpufreq_config(const std::string& fname, const std::string& value) {
  for (const std::string& cpu : list_cpus()) {
    set_contents(cpu + fname, value);
  }
}

void set_governor(const std::string& governor) {
  set_cpufreq_config("scaling_governor", governor);
}

void reset_min_max() {
  for (const std::string& cpu : list_cpus()) {
    set_contents(cpu + "scaling_max_freq", read_contents(cpu + "cpuinfo_max_freq"));
    set_contents(cpu + "scaling_min_freq", read_contents(cpu + "cpuinfo_min_freq"));
  }
}

int main(int argc, char* argv[]) {
  if (argc == 1) {
    set_governor("performance");
    reset_min_max();
  } else if (argc == 2 && argv[1] == "performance"s) {
    set_governor("performance");
    reset_min_max();
  } else if (argc == 2 && argv[1] == "powersave"s) {
    set_governor("powersave");
    reset_min_max();
  } else if (argc == 2 && argv[1] == "benchmark"s) {
    set_governor("performance");
    set_cpufreq_config("scaling_max_freq", "3000000");
    set_cpufreq_config("scaling_min_freq", "3000000");
  } else {
    std::cout << "usage: " << argv[0]
              << " [powersave|performance|benchmark|info]" << std::endl;
    exit(1);
  }
  print_info();
}
