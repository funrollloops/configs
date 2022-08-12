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

static constexpr std::string_view kGovernor = "scaling_governor";
static constexpr std::string_view kScaleMax = "scaling_max_freq";
static constexpr std::string_view kScaleMin = "scaling_min_freq";
static constexpr std::string_view kScaleCur = "scaling_cur_freq";
static constexpr std::string_view kCPUMax = "cpuinfo_max_freq";
static constexpr std::string_view kCPUMin = "cpuinfo_min_freq";

std::string operator+(std::string_view a, std::string_view b) {
  return std::string(a).append(b);
}

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

void set_contents(const std::string& path, std::string_view contents) {
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
    const std::string kCPUDir = "/sys/devices/system/cpu";
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

void summarize(std::string_view filename) {
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
  summarize(kGovernor);
  std::cout << "\nscaling min, max:";
  summarize(kScaleMin);
  std::cout << ",";
  summarize(kScaleMax);
  std::cout << "\ncpu min, max:";
  summarize(kCPUMin);
  std::cout << ",";
  summarize(kCPUMax);
  std::cout << "\ncurrent freq:";
  summarize(kScaleCur);
  std::cout << std::endl;
}

void set_cpufreq_config(std::string_view fname, std::string_view value) {
  for (const std::string& cpu : list_cpus()) {
    set_contents(cpu + fname, value);
  }
}

void set_governor(const std::string& governor) {
  set_cpufreq_config("scaling_governor", governor);
}

void reset_min_max() {
  for (const std::string& cpu : list_cpus()) {
    set_contents(cpu + kScaleMax, read_contents(cpu + kCPUMax));
    set_contents(cpu + kScaleMin, read_contents(cpu + kCPUMin));
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
    for (const std::string& cpu : list_cpus()) {
      set_contents(cpu + kScaleMax, "4000000");
      set_contents(cpu + kScaleMin, read_contents(cpu + kCPUMin));
    }
    reset_min_max();
  } else if (argc == 2 && argv[1] == "benchmark"s) {
    set_governor("performance");
    set_cpufreq_config(kScaleMax, "3000000");
    set_cpufreq_config(kScaleMin, "3000000");
  } else if (argc == 2 && argv[1] == "info"s) {
    // Do nothing.
  } else {
    std::cout << "usage: " << argv[0]
              << " [powersave|performance|benchmark|info]" << std::endl;
    exit(1);
  }
  print_info();
}
