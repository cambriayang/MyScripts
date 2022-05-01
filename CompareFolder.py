import filecmp, sys, os
from os.path import walk, isfile, join, basename, normpath, splitext


def compare(folder1, folder2):
    dir1 = normpath(folder1)
    dir2 = normpath(folder2)
    len1 = len(dir1) + 1
    len2 = len(dir2) + 1
    files1 = []
    files2 = []
    excludes = []

    def visit(arg, dirname, names, files=files1, length=len1):
        if basename(dirname) != 'CVS':
            files += [join(dirname, file)[length:].replace('\\', '/')
                      for file in names if isfile(join(dirname, file))
                      and splitext(file)[1].lower() not in excludes]

    walk(dir1, visit, 0)

    files1.sort()

    def visit(arg, dirname, names, files=files2, length=len2):
        if basename(dirname) != 'CVS':
            files += [join(dirname, file)[length:].replace('\\', '/')
                      for file in names if isfile(join(dirname, file))
                      and splitext(file)[1].lower() not in excludes]

    walk(dir2, visit, 0)

    files2.sort()

    common = []
    i = 0

    length = len(files1)

    while i < length:
        f = files1[i]
        try:
            t = files2.index(f)
        except:
            t = -1

        if t >= 0:
            common.append(f)
            del files1[i]
            del files2[t]
            length -= 1
        else:
            i += 1

    match, mismatch, error = filecmp.cmpfiles(dir1, dir2, common)

    print ('\n\n================ The particular files only in [%s] =================' % dir1)

    for f in files1:
        print ('1|%s|1' % f)

    print ('\n\n================ The particular files only in [%s] =================' % dir2)

    for f in files2:
        print ('2|%s|2' % f)

    # for f in match:
    #   print ('= %s' % f)

    print ('\n\n================ The different files in [%s] and [%s] =================' % (dir1, dir2))
    for f in mismatch:
        print ('>|%s|<' % f)