# How to upload NassakhRTL to GitHub

Step-by-step guide to push all files to your repo at  
**https://github.com/talhabinmunir/nassakhrtl**

---

## Option A — GitHub Desktop (easiest, no command line)

Best if you have not used Git before.

### Step 1: Download GitHub Desktop

Go to https://desktop.github.com and install it. Sign in with your GitHub account (talhabinmunir).

### Step 2: Clone your repo

1. Open GitHub Desktop.
2. Click **File → Clone repository**.
3. Go to the **URL** tab.
4. Paste: `https://github.com/talhabinmunir/nassakhrtl`
5. Choose a local folder, e.g. `C:\Projects\nassakhrtl`.
6. Click **Clone**.

### Step 3: Copy the files in

Open File Explorer and copy all the downloaded NassakhRTL files into the cloned folder:

```
C:\Projects\nassakhrtl\
  NassakhRTL.bat
  NassakhRTL.ps1
  README.md
  INSTRUCTIONS.md
  CHANGELOG.md
  CONTRIBUTING.md
  LICENSE
  .gitignore
  assets\
    NassakhRTL-icon.svg
    NassakhRTL-logo.svg
    screenshot-light.png
    screenshot-dark.png
  .github\
    ISSUE_TEMPLATE\
      bug_report.md
      feature_request.md
```

### Step 4: Commit and push

1. Switch back to GitHub Desktop. You will see all the new files listed on the left.
2. At the bottom left, type a commit message: `Initial release — NassakhRTL 1.0`
3. Click **Commit to main**.
4. Click **Push origin** (top bar).

Done. Go to https://github.com/talhabinmunir/nassakhrtl — your files are live.

---

## Option B — Command line (Git)

### Prerequisite: install Git

If you do not have Git: https://git-scm.com/download/win — install with default settings.

### Step 1: Open a terminal in the folder

Put all the NassakhRTL files into one folder, e.g. `C:\Projects\nassakhrtl\`.

Open PowerShell or Command Prompt, then navigate there:

```powershell
cd C:\Projects\nassakhrtl
```

### Step 2: Set your identity (once per machine)

```powershell
git config --global user.name "Talha bin Munir"
git config --global user.email "tlhmunir@gmail.com"
```

### Step 3: Initialize and connect

```powershell
git init
git remote add origin https://github.com/talhabinmunir/nassakhrtl.git
```

### Step 4: Stage everything

```powershell
git add .
```

### Step 5: Commit

```powershell
git commit -m "Initial release — NassakhRTL 1.0"
```

### Step 6: Push

```powershell
git branch -M main
git push -u origin main
```

Git will ask for your GitHub username and password. For the password, use a **Personal Access Token** (not your account password) — see below.

---

## Creating a Personal Access Token (PAT)

GitHub no longer accepts account passwords via command line.

1. Go to https://github.com/settings/tokens
2. Click **Generate new token → Generate new token (classic)**
3. Give it a name: `nassakhrtl-push`
4. Set expiration: 90 days (or No expiration)
5. Tick the **repo** scope checkbox
6. Click **Generate token**
7. **Copy the token immediately** — you will not see it again

When Git asks for your password during `git push`, paste this token.

---

## After uploading — create a Release

A Release lets users download a clean zip of just the two app files.

1. Go to https://github.com/talhabinmunir/nassakhrtl
2. On the right sidebar, click **Releases → Create a new release**
3. Click **Choose a tag → Create new tag** — type `v1.0.0`
4. Release title: `NassakhRTL 1.0`
5. Description: paste from CHANGELOG.md
6. Click **Attach binaries** and upload `NassakhRTL.bat` and `NassakhRTL.ps1`
7. Click **Publish release**

Users can now find the download at  
https://github.com/talhabinmunir/nassakhrtl/releases/latest

---

## Updating files later

When you make changes to the app, repeat just these steps:

```powershell
cd C:\Projects\nassakhrtl
git add .
git commit -m "brief description of what changed"
git push
```

---

## Contact

Talha bin Munir — tlhmunir@gmail.com
