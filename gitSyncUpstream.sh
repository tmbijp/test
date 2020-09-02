#!/bin/bash
#
#  git local workspaceに上位リポジトリの変更を同期する
#
# 1.scriptの設置
#   このscriptを$HOME/bin(なければ作成)に放り込んで置き
#   $HOME/binにPATHが通っていなければ通しておく
# 
# 2.localのgit work spaceの準備
#   git clone <my_git_url>
#   cd <git_dir>
#   git status (git work spaceであることの確認)
#   git branch -a (branch listの表示)
#   git checkout <any_branch> (master以外の任意のbranchにswitchする)(remotea addの前に行っておく)
#   git remote add upstream <upstream_git_url>
#   git remote -v (確認)
#   git fetch upstream
#   git branch -a (remotes/originとremotes/upstreamの両方に対象branchが存在することを確認)
#   ここまでやっていればこのscriptをgit work spaceで実行することでupsteamを同期する
#
# 3.注意点
#   追いかけるbranchはupstreamから同期するのみにしておきローカルからは更新しないこと
#   実行時には現在のブランチへの(git管理下のファイル)はcommitしておくこと
#   追いかけるbranch名はtrace_branchにセットする

trace_branch="v1.0.0"

# localがgit work spaceか確認
git_status_err="$(git status -s 2>&1 1> /dev/null )"
if [ "$git_status_err" ];then
  echo "$git_status_err"
  echo "git status取得に失敗したため処理を中止します"
  exit
fi

# git branchをキャッシュ
git_branch="$(git branch -a)"
current_branch=$(echo "$git_branch"|grep '^* '|awk '{ print $2 }')

if [ "$(echo "$git_branch"|grep "remotes/origin/${trace_branch}")" = "" ];then
  echo "cannot find remote branch: remotes/origin/${trace_branch}"
  exit
fi
if [ "$(echo "$git_branch"|grep "remotes/upstream/${trace_branch}")" = "" ];then
  echo "cannot find upstream branch: remotes/upstream/${trace_branch}"
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

# 自分のリポジトリにpushする場合コメントを外す
# echo -n "try to push?[N/y]:"
# read input
# if [ "$input" = "Y" ] || [ "$input" = "y" ];then
#   git push origin $trace_branch
# fi

# 元のbranchにswitch
if [ "$current_branch" != "$trace_branch" ];then
  git checkout "$current_branch"
fi

