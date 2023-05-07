import os
import unittest as ut
import subprocess as proc

main_dir = __file__.rstrip("/tests/test.py")

if __name__ == "__main__":
    result: proc.CompletedProcess \
       = proc.run([f"{main_dir}/build/verbose", f"{main_dir}/verbose_mockup.ver"], universal_newlines=True)
    print(result.stdout)
