#!/usr/bin/env python3
from random import choice
from math import log

words = [x.strip() for x in open('/usr/share/dict/words').readlines()]
words = list(
    set(w for w in words if 3 < len(w) < 9 and w.isalpha() and w.islower()))

print('entropy=%s bits' % (3 * log(len(words)) / log(2)))

print(' '.join(choice(words) for _ in range(4)))
