## 分支规范
项目基本遵循 [git-flow](https://www.git-tower.com/learn/git/ebook/cn/command-line/advanced-topics/git-flow) 工作流程。
仓库中有 2 个主分支和 1 个用于发版测试的 release 分支：

* **master**: 只能用来包括产品代码。不能直接工作在 master 分支上，而是在其他指定的，独立的特性分支中。不直接提交改动到 master 分支。
* **develop**: 是进行任何新的开发的基础分支。
* **release**: 发版测试分支。

### 分支命名规范
#### feature 分支
特性分支，`feat/` 开头。

当开始一个新的功能开发时，从 `develop` 分支创建以 `feat/xxx` 命名的本地分支进行开发，通常 xxx 是你的名字缩写加上 dev，比如张三拉取 `feat/zsdev`。

如果提交 `merge request`，请求合并至 `develop` 前，应确认开发分支是否已合并了其它分支的提交，如果有请先执行 `git pull --rebase origin develop`，保持提交历史整齐。

**tips：将本地 `feat` 分支 `git push` 前，先执行 `git pull --rebase origin develop`，就不必再人工确认是否之前有其他提交。**

#### hotfix分支
修复分支，`hotfix/` 开头。

如果发现紧急线上 bug，从最新的 `master` 分支建立 `hotfix` 分支，提交修复代码、测试无误后，合并至 `develop` 和 `master`。上线验证无误后，即可将 `hotfix` 分支删除。

## commit 规范
### Commit message 的格式
每次提交代码，都要写 `commit message`（提交说明），否则就不允许提交。要求 `commit message` 应该清晰明了，说明本次提交的目的。

提交的 `commit message` 包含三部分：`type`（必需）、`scope`（可选）和`subject`（必需）。

#### 1.type
`type` 用于说明 `commit` 的类别，只允许使用下面 7 个标识。

* feat：新功能（feature）
* fix：修补 bug
* docs：文档（documentation）
* style：格式（不影响代码运行的变动）
* refactor：重构（即不是新增功能，也不是修改 bug 的代码变动）
* test：增加测试
* chore：构建过程或辅助工具的变动

#### 2.scope
`scope` 用于说明 `commit` 影响的范围，比如网络层、登录模块等等，可不写。

#### 3.subject
`subject` 是 `commit` 目的的简短描述，不超过 50 个字符，不要使用结束符号`.`。

#### Revert
还有一种特殊情况，如果当前 `commit` 用于撤销以前的 `commit`，则必须以 `revert:` 开头，后面跟着被撤销 `commit` 的 `commit message`。
