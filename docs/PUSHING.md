# 推送到 GitHub

仓库：`OUCO86/dlss-nr-on-a770`，remote 走 SSH（`ssh://git@ssh.github.com:443`），
私钥无口令，**不需要 token**。分支只有一个：`windows`。

## 就这三行

```
git push                          # 推 windows（已设 upstream）
git push origin <标签名>          # 推标签
git push --force origin <标签名>  # 推移动过的标签
```

一键脚本：`tools\push_github.bat`（仓库外，见 `backups\host-tools`）。

## 绝对不要用的两条

| 命令 | 会发生什么 |
|---|---|
| `git push --tags` | 现在已无害（孤儿标签已清空），但**一旦有人新建了指向浅边界外的标签就会失败**，报错是看不懂的 `index-pack failed`。要推标签就写名字。 |
| `git push --all` | **必失败**。会把 `backup/api-built-windows`、`backup/shallow-windows`、`backup/v0.0.1-history`、`windows-fixed` 一起推，这几个分支的历史不完整。 |

## 为什么会有这种事

这个仓库是**浅克隆**：`.git/shallow` 里有 8 个 graft 点，其中 3 个的父对象是真的没有了
（`d9d1ff9`、`a987ec3`、`8f8e5bd`）。远程又只有 `windows` 一个分支，所以
`git fetch --unshallow` 拉不到任何东西（返回成功，但 shallow 文件原封不动）。

**已经查过、确认拿不到的来源**（别再查第二遍）：备份 `.git`、两个 bundle、
`dlss-nr-on-intel`、`a770-speedopt/repo`、`dlss5-on-amd-9070xt-porting`、`dlss5nr-b580`。
浅仓库建的 bundle 救不了浅仓库——那个 `repo-all.bundle` fetch 出来是 0 个新对象。

## 好消息：远程仓库是健康的

`windows` 分支 55 个 commit，根 `38fb6fd`，父链和 tree **零缺失**。
日常推送、别人完整 clone 都正常。只有孤儿引用受影响，不用为 shallow 焦虑。

## 出错时怎么判断

| 症状 | 原因 | 动作 |
|---|---|---|
| `index-pack failed` / `did not receive expected object` | 要推的东西引用了浅边界外的历史 | 别推它。把那个标签改成分支留在本地（见下） |
| `remote rejected` + failed | 同上 | 同上 |
| `Everything up-to-date` 但 GitHub 上看不到 | 推的是旧分支或标签没推 | 显式写名字再推一次 |

**注意**：shallow 会掩盖缺失。`git rev-list --objects X | git cat-file --batch-check | grep missing`
会报 0 缺失，因为 `rev-list` 走到 graft 点就停了。要看清得手动沿 parent 遍历。

## 孤儿历史怎么留

推不上去又不想丢的提交，改成分支，别留成标签：

```
git branch backup/<名字> <commit>
git tag -d <标签名>
```

`v0.0.1` 就是这么处理的，现在叫 `backup/v0.0.1-history`（指向 `7f9c364`）。
要还原：`git tag v0.0.1 backup/v0.0.1-history`（但依然推不上去）。

## 当前标签

`a770-int8-verified`（annotated）→ `98c123f`，2026-10-11 在游戏里验证过的那一版。
