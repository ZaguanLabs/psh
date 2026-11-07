.PHONY: all build test sanitize bench clean
SANITIZER_CC ?= $(CC)
BENCH_CFLAGS ?= -O2 -g
all: build
build:
	zsh -df scripts/build.zsh
test: build
	python3 tests/test_module.py
	python3 tests/test_build.py
	$(CC) -std=c11 -Wall -Wextra -Wpedantic -Werror -fPIC -shared -Isrc -Ivendor/md4c src/render.c src/grapheme.c vendor/md4c/md4c.c vendor/md4c/entity.c vendor/md4c/md4c-html.c -o .build/conformance.so
	LC_ALL=C.UTF-8 python3 tests/conformance.py
	python3 scripts/unicode-tables.py --check
	LC_ALL=C.UTF-8 python3 tests/graphemes.py
	LC_ALL=C.UTF-8 python3 tests/structured_core.py
sanitize:
	mkdir -p .build
	$(SANITIZER_CC) -std=c11 -Wall -Wextra -Wpedantic -Werror -g -O1 -fsanitize=address,undefined -fno-omit-frame-pointer -Isrc -Ivendor/md4c tests/stress.c src/render.c src/grapheme.c vendor/md4c/md4c.c vendor/md4c/entity.c -o .build/stress
	LC_ALL=C.UTF-8 ASAN_OPTIONS=detect_leaks=1 .build/stress
bench: build
	mkdir -p .build/bench
	$(CC) -std=c11 -Wall -Wextra -Wpedantic -Werror $(BENCH_CFLAGS) -Isrc -Ivendor/md4c tests/benchmark.c src/render.c src/grapheme.c vendor/md4c/md4c.c vendor/md4c/entity.c -o .build/bench/render-bench
	python3 scripts/benchmark.py --module-dir ".build/$(ZMDOWN_BUILD_NAME)/modules"
clean:
	rm -rf .build/zsh .build/modules .build/source-root
