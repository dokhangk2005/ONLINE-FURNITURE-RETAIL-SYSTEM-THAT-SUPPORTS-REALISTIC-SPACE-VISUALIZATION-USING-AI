import sys
import zipfile


def main():
    args = sys.argv[1:]
    if len(args) == 2 and args[0] == "-Z1":
        with zipfile.ZipFile(args[1]) as archive:
            for name in archive.namelist():
                print(name)
        return
    if len(args) == 3 and args[0] == "-p":
        with zipfile.ZipFile(args[1]) as archive:
            sys.stdout.buffer.write(archive.read(args[2]))
        return
    raise SystemExit("Unsupported unzip arguments: " + repr(args))


if __name__ == "__main__":
    main()
