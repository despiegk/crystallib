# GitTools

Are good tools to allow you to work with GIT in a programatic way

Git repo's get checked out under

- multibranch: $homedir/code/multi/accountname/reponame/branchname/code 
- single brach (default): $homedir/code/accountname/reponame/code

>TODO: need to check this multibranch could be its broken

## 3script

```js

gittools.git_do .
    coderoot //location where code will be checked out .
    filter // if used will only show the repo's which have the filter string inside .
    repo            .
    account         .
    provider        .
    print          bool = true .
    pull           bool // means when getting new repo will pull even when repo is already there .
    pullreset      bool // means we will force a pull and reset old content	 .
    commit         bool .
    commitpull     bool .
    commitpush     bool .
    commitpullpush bool .
    msg            string .
    delete         bool // remove the repo . 
    script         bool = true // run non interactive (default for actions) .
    cachereset     bool //remove redis cache .
gittools.git_get .
    coderoot //location where code will be checked out .
    pull           bool // means when getting new repo will pull even when repo is already there .
    pullreset      bool // means we will force a pull and reset old content	 .

```

## Objects

- Structure of all found gitrepo's
- GitRepo
  - linked to one or more git addresses
  - linked to a specific repository as its stored on the local filesystem
  - links to gitstructure
- GitAddress
  - links to gitstructure
  - can retrieve gitrepo from it but not linked
- GitLocator
  - always has GitAddress
  - a gitlocator is nothing without gitaddress

## Get a repo

This is the most basic usecase

>> TODO: check

```v
import gittools

mut gs:=gittools.get()?
url := "https://github.com/threefoldfoundation/www_examplesite/tree/development/manual"
mut gr := gs.repo_get_from_url(url:url,pull:false, reset:false)

println(gr)

println(gr.path_content_get())

```

result is something like


```v

GitRepo{
    id: 8
    path: '/Users/despiegk1/code/github/threefoldfoundation/www_examplesite'
    addr: freeflowuniverse.crystallib.gittools.GitAddr{
        provider: 'github.com'
        account: 'threefoldfoundation'
        name: 'www_examplesite'
        path: 'manual'
        branch: 'development'
        anker: ''
        depth: 0
    }
    state: ok
}

#THIS IS THE PATH WHERE THE CONTENT GOT CHECKED OUT
/Users/despiegk1/code/github/threefoldfoundation/www_examplesite/manual

- bettertoken/info_bettertoken                 development             CHANGED
- despiegk/data                                master                  CHANGED
- despiegk/htmx_vweb                           master                  CHANGED
- freeflowtribe/info_thesourcecode             development             CHANGED
- freeflowuniverse/crystallib                  development_publisher3  CHANGED
- freeflowuniverse/crystaltools                development_refactor    CHANGED
- freeflowuniverse/freeflow_network            main                    CHANGED
- freeflowuniverse/home                        development             CHANGED
- freeflowuniverse/info_freeflow_internal      development             CHANGED
- freeflowuniverse/info_freeflow_pub           development             CHANGED
- freeflowuniverse/twinactions                 development             CHANGED
- omni-sphere/info_vlang                       main                    CHANGED
- ourworld-tsc/ourworld_books                  development             CHANGED
- ourworld-tsc/ourworld_digital_bank           main                    CHANGED

```

## GIT ADDRESS

```
url := 'https://github.com/vlang/v/blob/master/doc/docs.md#maps'
obj := addr_get_from_url(url) or { panic('$err') }

//result ->
GitAddr{
    provider: 'github.com'
    account: 'vlang'
    name: 'v'
    path: 'doc/docs.md'
    branch: 'master'
    anker: 'maps'
    depth: 0
}

//another example starting from git@ ... url, works in same way
url := 'git@github.com:crystaluniverse/publishtools/tree/development/doc'
obj := addr_get_from_url(url) or { panic('$err') }

tocompare := GitAddr{
    provider: 'github.com'
    account: 'crystaluniverse'
    name: 'publishtools'
    path: 'doc'
    branch: 'development'
    anker: ''
    depth: 0
}

```

is a cool mechanism to get the unique location to a part on page from a url

## USAGE OF ENV VARIABLES

```v
if 'MULTIBRANCH' in os.environ() {
    gs.multibranch = true
}

if 'DIR_CODE' in os.environ() {
    gs.config.root = os.environ()['DIR_CODE'] + '/'
} else {
    gs.config.root = '$os.home_dir()/code/'
}
```

> MULTIBRANCH and DIR_CODE can be set

- multibranch means we will checkout under $homedir/code/multi/accountname/reponame/branchname/code 
    - in stead of  $homedir/code/accountname/reponame/code