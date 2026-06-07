# GCC Cheatsheet

`gcc` is the GNU C compiler. `cc` is the generic C compiler command and may point
to GCC depending on the system.

## Daily Compile Commands

### Compile one C file
gcc main.c

### Compile and name the output
gcc main.c -o app

### Compile multiple source files
gcc main.c util.c -o app

### Compile with common warnings
gcc -Wall -Wextra -pedantic main.c -o app

### Compile for debugging
gcc -g -Wall -Wextra main.c -o app

### Compile with optimization
gcc -O2 -Wall -Wextra main.c -o app

---

## Build Steps

### Compile only, produce object file
gcc -c main.c

### Compile object with explicit output name
gcc -c main.c -o main.o

### Link object files
gcc main.o util.o -o app

### Stop after preprocessing
gcc -E main.c

### Produce assembly
gcc -S main.c

---

## Standards

### Use C11
gcc -std=c11 main.c -o app

### Use C17
gcc -std=c17 main.c -o app

### Use C23/GNU C23 when supported
gcc -std=c23 main.c -o app
gcc -std=gnu23 main.c -o app

### Strict ISO C plus warnings
gcc -std=c17 -Wall -Wextra -pedantic main.c -o app

---

## Includes And Libraries

### Add an include directory
gcc -Iinclude main.c -o app

### Include headers and link the matching library
gcc -Iinclude main.c -Llib -lmylib -o app

### Link a bundled shared library from ./lib at runtime
gcc -Iinclude main.c -Llib -Wl,-rpath,'$ORIGIN/lib' -lmylib -o app

### Same rpath using explicit linker forwarding
gcc -Iinclude main.c -Llib -Xlinker -rpath -Xlinker '$ORIGIN/lib' -lmylib -o app

### Add a library search directory
gcc main.c -Llib -lmylib -o app

### Link the math library
gcc main.c -lm -o app

### Link pthreads
gcc main.c -pthread -o app

### Define a macro
gcc -DDEBUG main.c -o app

### Define a macro with a value
gcc -DVERSION=\"1.0\" main.c -o app

---

## Debugging And Checking

### Debug build with no optimization
gcc -g -O0 -Wall -Wextra main.c -o app

### Address sanitizer
gcc -g -fsanitize=address -fno-omit-frame-pointer main.c -o app

### Undefined behavior sanitizer
gcc -g -fsanitize=undefined main.c -o app

### Both common sanitizers
gcc -g -fsanitize=address,undefined -fno-omit-frame-pointer main.c -o app

### Treat warnings as errors
gcc -Wall -Wextra -Werror main.c -o app

### Show more warning context
gcc -fdiagnostics-color=always -Wall -Wextra main.c -o app

---

## Dependencies For Makefiles

### Print header dependencies
gcc -M main.c

### Generate dependency file beside object file
gcc -MMD -MP -c main.c -o main.o

### Typical object build command
gcc -Wall -Wextra -MMD -MP -c main.c -o main.o

---

## Useful Inspection

### Show GCC version
gcc --version

### Show full compiler commands
gcc -v main.c -o app

### Show default include paths and target info
gcc -v -E - </dev/null

### List supported target options
gcc -Q --help=target

### List supported warnings
gcc -Q --help=warnings

---

## Common Patterns

### Small project
gcc -std=c17 -Wall -Wextra -g main.c util.c -o app

### Release-ish build
gcc -std=c17 -O2 -DNDEBUG -Wall -Wextra main.c util.c -o app

### Debug sanitizer build
gcc -std=c17 -g -O0 -fsanitize=address,undefined -fno-omit-frame-pointer -Wall -Wextra main.c util.c -o app

### Compile with all headers under include/
gcc -std=c17 -Iinclude -Wall -Wextra src/*.c -o app

---

## Notes

- Put options before source files when possible.
- Put libraries after the objects or source files that need them.
- `-Iinclude` only tells GCC where to find headers; it does not link library code.
- A header provides declarations used while compiling. A library provides the compiled function bodies needed while linking.
- `-lmylib` tells the linker to search for `libmylib.so` or `libmylib.a`; omit the `lib` prefix and file extension.
- A dynamically linked `.so` must also be findable when the program runs, such as through the system library path, `LD_LIBRARY_PATH`, or an rpath.
- `-Wl,option` passes `option` through GCC to the linker. Use `-Wl,-rpath,'$ORIGIN/lib'`, not `-rpath` by itself.
- Do not put a space after `-Wl,`. `-Wl,-rpath,'$ORIGIN/lib'` is one comma-packed GCC argument; `-Wl, -rpath,'$ORIGIN/lib'` splits it and makes GCC see `-rpath` directly.
- `-Wl,-rpath,'$ORIGIN/lib'` is equivalent to `-Xlinker -rpath -Xlinker '$ORIGIN/lib'`.
- `$ORIGIN` in an rpath is expanded by the dynamic loader to the directory containing the executable. It is not a shell variable, so `echo "$ORIGIN"` normally prints nothing.
- Use `-g` for debug symbols and `-O0` when stepping through code.
- Use `-O2` for normal optimized builds; reach for `-O3` only after measuring.
- Start with `-Wall -Wextra`; add `-Werror` only when you want warnings to fail the build.
- Use sanitizers during development to catch memory and undefined behavior bugs early.
