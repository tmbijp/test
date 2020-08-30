#!/bin/bash
# 追いかけるbranch
trace_branch="v1.0.0"

# localがgit work spaceか確認
git_status="$(git status -s 2>&1 1> /dev/null )"
if [ "$git_status" ];then
  echo "$git_status"
  echo "git status取得に失敗したため処理を中止します"
  exit
fi

# git branchをキャッシュ
git_branch="$(git branch -a)"
current_branch=$(echo "$git_branch"|grep '^* '|awk '{ print $2 }')

if [ "$(echo "$git_branch"|grep "remotes/origin/$trace_branch")" = "" ];then
  echo "cannot find local branch remotes/origin/$trace_branch"
  exit
fi
if [ "$(echo "$git_branch"|grep "remotes/upstream/$trace_branch")" = "" ];then
  echo "cannot find local branch remotes/upstream/$trace_branch"
  exit
fi

# trace_branchにswitch
if [ "$current_branch" != "$trace_branch" ];then
  git checkout "$trace_branch"
fi
# upstreamを取得
git fetch upstream
#merge
git merge "upstream/${trace_branch}"

# 元のbranchにswitch
if [ "$current_branch" != "$trace_branch" ];then
  git checkout "$current_branch"
fi

