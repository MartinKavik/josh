  $ export TESTTMP=${PWD}
  $ export PATH=${TESTDIR}/../../target/debug/:${PATH}

  $ cd ${TESTTMP}
  $ git init real_repo &>/dev/null
  $ cd real_repo

  $ mkdir sub1
  $ echo contents1 > sub1/file1
  $ git add sub1
  $ git commit -m "add file1" &> /dev/null

  $ mkdir sub2
  $ echo contents1 > sub2/file2
  $ git add sub2
  $ git commit -m "add file2" &> /dev/null

  $ josh-filter master:refs/heads/hidden :hide=sub2
  $ git checkout hidden &> /dev/null
  $ tree
  .
  `-- sub1
      `-- file1
  
  1 directory, 1 file
  $ git log --graph --pretty=%s
  * add file1

  $ echo contents3 > sub1/file3
  $ git add sub1/file3
  $ git commit -m "add sub1/file3" &> /dev/null

  $ josh-filter --reverse master:refs/heads/hidden :hide=sub2

  $ git checkout master
  Switched to branch 'master'

  $ tree
  .
  |-- sub1
  |   |-- file1
  |   `-- file3
  `-- sub2
      `-- file2
  
  2 directories, 3 files


  $ cat sub1/file3
  contents3

  $ git log --graph --pretty=%s
  * add sub1/file3
  * add file2
  * add file1
