  $ source ${TESTDIR}/setup_test_env.sh
  $ cd ${TESTTMP}


  $ git clone -q http://${TESTUSER}:${TESTPASS}@localhost:8001/real_repo.git
  warning: You appear to have cloned an empty repository.

  $ curl -s http://localhost:8002/version
  Version: * (glob)

  $ cd real_repo

  $ git status
  On branch master
  
  No commits yet
  
  nothing to commit (create/copy files and use "git add" to track)

  $ git checkout -b master
  Switched to a new branch 'master'
  $ echo content1 > file1 &> /dev/null
  $ git add .
  $ git commit -m "initial" &> /dev/null

  $ git checkout -b new1
  Switched to a new branch 'new1'
  $ echo content > newfile1 &> /dev/null
  $ git add .
  $ git commit -m "add newfile1" &> /dev/null

  $ git checkout master &> /dev/null
  $ echo content > newfile_master &> /dev/null
  $ git add .
  $ git commit -m "newfile master" &> /dev/null

  $ git merge new1 --no-ff
  Merge made by the 'recursive' strategy.
   newfile1 | 0
   1 file changed, 0 insertions(+), 0 deletions(-)
   create mode 100644 newfile1

  $ mkdir sub3
  $ echo contents3 > sub3/file3
  $ git add sub3
  $ git commit -m "add file3" &> /dev/null

  $ mkdir -p sub1/subsub
  $ echo contents1 > sub1/subsub/file1
  $ git add .
  $ git commit -m "add file1" &> /dev/null

  $ mkdir sub2
  $ echo contents1 > sub2/file2
  $ git add sub2
  $ git commit -m "add file2" &> /dev/null


  $ git log --graph --pretty=%s
  * add file2
  * add file1
  * add file3
  *   Merge branch 'new1'
  |\  
  | * add newfile1
  * | newfile master
  |/  
  * initial

  $ git push
  To http://localhost:8001/real_repo.git
   * [new branch]      master -> master

  $ cd ${TESTTMP}
  $ cat > viewfile <<EOF
  > real_repo.git
  > / : !empty/empty
  > a/b : !/sub2
  > c : !/sub1
  > EOF
  $ X=$(curl -s http://localhost:8002/view --upload-file viewfile)
  $ git clone -q http://${TESTUSER}:${TESTPASS}@localhost:8002/view/${X}/ stored
  $ cd stored
  $ tree
  .
  |-- a
  |   `-- b
  |       `-- file2
  `-- c
      `-- subsub
          `-- file1
  
  4 directories, 2 files

  $ git log --graph --pretty=%s
  * add file2
  * add file1

  $ git checkout HEAD~1 &> /dev/null

  $ tree
  .
  `-- c
      `-- subsub
          `-- file1
  
  2 directories, 1 file

  $ git checkout master &> /dev/null

  $ echo newfile_1_contents > c/subsub/newfile_1
  $ echo newfile_2_contents > a/b/newfile_2

  $ git add .

  $ git commit -m "add in view" &> /dev/null

  $ git push &> /dev/null

  $ cd ${TESTTMP}/real_repo

  $ git pull &> /dev/null

  $ tree
  .
  |-- file1
  |-- newfile1
  |-- newfile_master
  |-- sub1
  |   `-- subsub
  |       |-- file1
  |       `-- newfile_1
  |-- sub2
  |   |-- file2
  |   `-- newfile_2
  `-- sub3
      `-- file3
  
  4 directories, 8 files
  $ git log --graph --pretty=%s
  * add in view
  * add file2
  * add file1
  * add file3
  *   Merge branch 'new1'
  |\  
  | * add newfile1
  * | newfile master
  |/  
  * initial

  $ bash ${TESTDIR}/destroy_test_env.sh
