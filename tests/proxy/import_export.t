  $ source ${TESTDIR}/setup_test_env.sh

  $ git init --bare ${TESTTMP}/remote/repo1.git/ &> /dev/null
  $ git config -f ${TESTTMP}/remote/repo1.git/config http.receivepack true
  $ git init --bare ${TESTTMP}/remote/repo2.git/ &> /dev/null
  $ git config -f ${TESTTMP}/remote/repo2.git/config http.receivepack true

  $ cd ${TESTTMP}
  $ git clone -q http://${TESTUSER}:${TESTPASS}@localhost:8001/repo1.git
  warning: You appear to have cloned an empty repository.
  $ cd ${TESTTMP}/repo1 &> /dev/null
  $ echo content1 > file1 &> /dev/null
  $ git add file1 &> /dev/null
  $ git commit -m "initial1" &> /dev/null
  $ git push
  To http://localhost:8001/repo1.git
   * [new branch]      master -> master

  $ cd ${TESTTMP}
  $ git clone -q http://${TESTUSER}:${TESTPASS}@localhost:8001/repo2.git
  warning: You appear to have cloned an empty repository.
  $ cd ${TESTTMP}/repo2 &> /dev/null
  $ echo content2 > file2 &> /dev/null
  $ git add file2 &> /dev/null
  $ git commit -m "initial2" &> /dev/null
  $ git push
  To http://localhost:8001/repo2.git
   * [new branch]      master -> master

  $ cd ${TESTTMP}
  $ git clone -q http://${TESTUSER}:${TESTPASS}@localhost:8001/real_repo.git &> /dev/null
  $ cd real_repo
  $ git commit --allow-empty -m "initial" &> /dev/null
  $ git push &> /dev/null

  $ curl -s http://localhost:8002/flush
  Flushed credential cache
  $ git fetch --force http://${TESTUSER}:${TESTPASS}@localhost:8002/repo1.git!+/repo1.git master:repo1_in_subdir &> /dev/null
  $ git checkout repo1_in_subdir
  Switched to branch 'repo1_in_subdir'
  $ git log --graph --pretty=%s
  * initial1
  $ tree
  .
  `-- repo1
      `-- file1
  
  1 directory, 1 file

  $ curl -s http://localhost:8002/flush
  Flushed credential cache
  $ git fetch --force http://${TESTUSER}:${TESTPASS}@localhost:8002/repo2.git!+/repo2.git master:repo2_in_subdir &> /dev/null
  $ git merge -m "Combine" repo2_in_subdir --allow-unrelated-histories &> /dev/null

  $ git log --graph --pretty=%s
  *   Combine
  |\  
  | * initial2
  * initial1
  $ tree
  .
  |-- repo1
  |   `-- file1
  `-- repo2
      `-- file2
  
  2 directories, 2 files

  $ git checkout master
  Switched to branch 'master'
  Your branch is up to date with 'origin/master'.

  $ git merge -m "Import 1" repo1_in_subdir --allow-unrelated-histories &> /dev/null

  $ git log --graph --pretty=%s
  *   Import 1
  |\  
  | *   Combine
  | |\  
  | | * initial2
  | * initial1
  * initial

  $ echo new_content1 > repo1/new_file1 &> /dev/null
  $ git add repo1
  $ git commit -m "add new_file1" &> /dev/null

  $ tree
  .
  |-- repo1
  |   |-- file1
  |   `-- new_file1
  `-- repo2
      `-- file2
  
  2 directories, 3 files

  $ git push &> /dev/null

  $ cd ${TESTTMP}
  $ git clone -q http://${TESTUSER}:${TESTPASS}@localhost:8002/real_repo.git!/repo1.git r1 &> /dev/null
  $ cd r1

  $ git log --graph --pretty=%s
  * add new_file1
  * initial1

  $ tree
  .
  |-- file1
  `-- new_file1
  
  0 directories, 2 files

  $ cd ${TESTTMP}/repo1
  $ echo new_content2 > new_file2 &> /dev/null
  $ git add new_file2 &> /dev/null
  $ git commit -m "add new_file2" &> /dev/null
  $ git push
  To http://localhost:8001/repo1.git
     *..*  master -> master (glob)

  $ cd ${TESTTMP}/real_repo
  $ git checkout master &> /dev/null
  $ curl -s http://localhost:8002/flush
  Flushed credential cache
  $ git fetch --force http://${TESTUSER}:${TESTPASS}@localhost:8002/repo1.git!+/repo1.git master:repo1_in_subdir &> /dev/null
  $ git log --graph --pretty=%s repo1_in_subdir
  * add new_file2
  * initial1

  $ git merge -m "Import 2" repo1_in_subdir --allow-unrelated-histories &> /dev/null
  $ tree
  .
  |-- repo1
  |   |-- file1
  |   |-- new_file1
  |   `-- new_file2
  `-- repo2
      `-- file2
  
  2 directories, 4 files

  $ git log --graph --pretty=%s
  *   Import 2
  |\  
  | * add new_file2
  * | add new_file1
  * |   Import 1
  |\ \  
  | * \   Combine
  | |\ \  
  | | |/  
  | |/|   
  | | * initial2
  | * initial1
  * initial

  $ git push &> /dev/null

  $ cd ${TESTTMP}/r1
  $ curl -s http://localhost:8002/flush
  Flushed credential cache
  $ git pull &> /dev/null
  $ tree
  .
  |-- file1
  |-- new_file1
  `-- new_file2
  
  0 directories, 3 files
  $ git log --graph --pretty=%s
  *   Import 2
  |\  
  | * add new_file2
  * | add new_file1
  |/  
  * initial1

  $ cd ${TESTTMP}/repo1
  $ git commit --amend -m "add great new_file2" &> /dev/null
  $ git push --force
  To http://localhost:8001/repo1.git
   + *...* master -> master (forced update) (glob)

  $ cd ${TESTTMP}/real_repo
  $ git checkout master &> /dev/null
  $ curl -s http://localhost:8002/flush
  Flushed credential cache
  $ git fetch --force http://${TESTUSER}:${TESTPASS}@localhost:8002/repo1.git!+/repo1.git master:repo1_in_subdir &> /dev/null
  $ git log --graph --pretty=%s repo1_in_subdir
  * add great new_file2
  * initial1

  $ git merge -m "Import 3" repo1_in_subdir --allow-unrelated-histories &> /dev/null

  $ git log --graph --pretty=%s
  *   Import 3
  |\  
  | * add great new_file2
  * |   Import 2
  |\ \  
  | * | add new_file2
  | |/  
  * | add new_file1
  * |   Import 1
  |\ \  
  | * \   Combine
  | |\ \  
  | | |/  
  | |/|   
  | | * initial2
  | * initial1
  * initial

  $ git push &> /dev/null

  $ cd ${TESTTMP}/r1
  $ curl -s http://localhost:8002/flush
  Flushed credential cache
  $ git pull &> /dev/null
  $ tree
  .
  |-- file1
  |-- new_file1
  `-- new_file2
  
  0 directories, 3 files
  $ git log --graph --pretty=%s
  *   Import 3
  |\  
  | * add great new_file2
  * |   Import 2
  |\ \  
  | * | add new_file2
  | |/  
  * / add new_file1
  |/  
  * initial1


Empty roots should not be dropped -> sha1 equal guarantee for "nop"
  $ cd ${TESTTMP}
  $ curl -s http://localhost:8002/flush
  Flushed credential cache
  $ git clone -q http://${TESTUSER}:${TESTPASS}@localhost:8002/real_repo.git rr &> /dev/null
  $ cd rr
  $ git log --graph --pretty=%s
  *   Import 3
  |\  
  | * add great new_file2
  * |   Import 2
  |\ \  
  | * | add new_file2
  | |/  
  * | add new_file1
  * |   Import 1
  |\ \  
  | * \   Combine
  | |\ \  
  | | |/  
  | |/|   
  | | * initial2
  | * initial1
  * initial
  $ tree
  .
  |-- repo1
  |   |-- file1
  |   |-- new_file1
  |   `-- new_file2
  `-- repo2
      `-- file2
  
  2 directories, 4 files

  $ bash ${TESTDIR}/destroy_test_env.sh
  remote/scratch/refs
  |-- heads
  |-- josh
  |   |-- filtered
  |   |   |-- real_repo.git
  |   |   |   |-- %3A%2Frepo1
  |   |   |   |   `-- heads
  |   |   |   |       `-- master
  |   |   |   |-- %3A%2Frepo2
  |   |   |   |   `-- heads
  |   |   |   |       `-- master
  |   |   |   `-- %3Anop=nop
  |   |   |       `-- heads
  |   |   |           `-- master
  |   |   |-- repo1.git
  |   |   |   `-- %3Aprefix=repo1
  |   |   |       `-- heads
  |   |   |           `-- master
  |   |   `-- repo2.git
  |   |       `-- %3Aprefix=repo2
  |   |           `-- heads
  |   |               `-- master
  |   `-- upstream
  |       |-- real_repo.git
  |       |   `-- refs
  |       |       `-- heads
  |       |           `-- master
  |       |-- repo1.git
  |       |   `-- refs
  |       |       `-- heads
  |       |           `-- master
  |       `-- repo2.git
  |           `-- refs
  |               `-- heads
  |                   `-- master
  |-- namespaces
  `-- tags
  
  28 directories, 8 files
