#!/bin/bash
#
# git local workspaceに上流リポジトリの変更を同期する(forkしたリポジトリのfork元の変更を取り込む)
#
# Usage gitSyncUpstream.sh [trace_branch]
#   trace_branchは内部のtrace_branch以外で同期させたい場合に引数で指定する
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
#
# 4.自分のリポジトリにpushする場合に上流(upstream)と自分のリポジトリが一致しているかの確認
#   push後にgithubの自分のリポジトリのtrace_branchを選択して
#   ブランチ選択直後の画面に
#   "This branch is even with <upstream_repo>.<trace_branch>."
#   と表示されていたら自分のリポジトリのtrace_branchと上流(upstream)のtrace_branchが完全に一致していると確認できる。
#   この文言がない場合は自分のリポジトリのtrace_branchとupstreamのtrace_branchで内容が異なっていることになる。
#   このtrace_branchで何かの変更をcommit,pushしてしまっている可能性があるので確認が必要となる。
#
# 5.trace_branchの変更手順(upstreamに新規branchが追加されtrace_branchをそれに変更する場合) 手動で下記gitコマンドを実行する必要がある
#   例：v1.0.0 => v2.0.0 の変更の場合
#   git fetch upstream
#   git branch -a (upsteam/v2.0.0 が存在していることを確認)
#   git checkout v2.0.0(ローカルにv2.0.0ブランチにswitch(自動的に作成される)
#   git push origin v2.0.0  (リモートのoriginにv2.0.0を作成する)
#

# 追いかけたいbranch
trace_branch="v1.0.0"

#第一引数が存在していたらそれをtrace_branchとする
if [ "$1" != "" ];then
  trace_branch="$1"
fi

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
merge=$(git merge "upstream/${trace_branch}" 2>"/tmp/gitSync.$$")
merge_err="$(cat "/tmp/gitSync.$$")" && rm "/tmp/gitSync.$$"
echo "$merge"
if [ "$(echo "$merge"| grep -E '^Already up[- ]to[- ]date')" == "" ] && [ "$(echo "$merge_err"| grep 'Aborting')" == "" ];then 
  # 何かの更新を取り込んだ場合pushするか確認
  echo -n "try to push?[N/y]:"
  read input
  if [ "$input" = "Y" ] || [ "$input" = "y" ];then
    git push origin $trace_branch
  fi
else
  if [ "$merge_err" != "" ];then
    echo "$merge_err"
  fi
fi

# 元のbranchにswitch
if [ "$current_branch" != "$trace_branch" ];then
  git checkout "$current_branch"
fi

