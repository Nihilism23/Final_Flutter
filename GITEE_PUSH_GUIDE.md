# 推送到Gitee指南

## 方法一：使用自动脚本（推荐）

1. 双击运行 `push_to_gitee.bat` 文件
2. 按照提示操作即可

## 方法二：手动推送步骤

### 1. 初始化Git仓库
```bash
git init
```

### 2. 添加远程仓库
```bash
git remote add origin https://gitee.com/gcx_952128814/super_-weather_-schedule_1.git
```

### 3. 添加所有文件
```bash
git add .
```

### 4. 提交更改
```bash
git commit -m "feat: 初始化超级天气课程表项目"
```

### 5. 推送到Gitee
```bash
git branch -M master
git push -u origin master
```

## Git配置（如果是首次使用）

### 设置用户信息
```bash
git config --global user.name "你的名字"
git config --global user.email "你的邮箱"
```

## 常见问题

### Q: 提示需要输入用户名和密码
A: 在Gitee上设置SSH密钥或使用个人访问令牌（推荐）

### Q: 远程仓库已存在内容
A: 可以先拉取再推送，或使用强制推送（谨慎使用）
```bash
git pull origin main --allow-unrelated-histories
git push -u origin main
```

### Q: 如何生成SSH密钥
1. 生成SSH密钥：
```bash
ssh-keygen -t rsa -C "你的邮箱"
```
2. 在用户目录的 `.ssh` 文件夹中找到 `id_rsa.pub` 文件
3. 复制内容到Gitee的SSH公钥设置中

## 验证推送成功

访问以下地址检查：
https://gitee.com/gcx_952128814/super_-weather_-schedule_1

---

## 项目说明

这是一个现代化的Flutter课程表应用，集成了天气预报功能。

- 课程表管理（支持CSV导入）
- 实时天气预报
- 智能提醒服务
- 主题切换（浅色/深色）
- 现代化UI设计
