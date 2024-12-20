## Timings

| Option                | time real (s) | time user (s) | C-clock (s) |
| --------------------- | ------------- | ------------- | ----------- |
| No-precompile         | 1.199         | 1.612         | 1.667193    |
| Precompile-exec       | 0.352         | 0.777         | 0.820570    |
| Precompile-statements | 1.038         | 1.448s        | 1.503454    |
| Both                  | 0.355         | 0.774         | 0.823976    |

## Binary size

| Compiler        | libjetreconstruction.so | rest |
| --------------- | ----------------------- | ---- |
| PackageCompiler | 221M                    | 266M |
| juliac          | 178M                    | ?    |
