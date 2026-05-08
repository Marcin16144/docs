# Git — podstawy i komendy

## Czym jest Git?

**Git** to **rozproszony system kontroli wersji** (VCS) stworzony przez Linusa Torvaldsa w 2005 dla rozwoju kernela Linux. Standard branżowy w 2026 — używany w 95%+ projektów open source i komercyjnych.

### Co Git robi:
- Śledzi zmiany w plikach (kto, kiedy, co)
- Pozwala wracać do poprzednich wersji
- Łączy zmiany od wielu developerów (merging)
- Branche — równoległe linie rozwoju
- Współpraca przez zdalne repozytoria (GitHub, GitLab)

### Git vs alternatywy
| System | Status 2026 |
|--------|-------------|
| **Git** | ⭐ Standard |
| **Subversion (SVN)** | Legacy, niektóre enterprise |
| **Mercurial (hg)** | Niche (Facebook → migracja) |
| **Perforce (P4)** | Gaming, large binary files |
| **Bazaar** | Praktycznie martwy |

## Instalacja

### Windows
```powershell
# Opcja 1: Git for Windows (zalecane)
# Pobierz z git-scm.com/download/win
# Zawiera Git Bash (MSYS2), Git GUI

# Opcja 2: winget
winget install --id Git.Git -e

# Opcja 3: scoop / chocolatey
scoop install git
choco install git
```

### macOS
```bash
# Opcja 1: Homebrew (zalecane)
brew install git

# Opcja 2: Xcode Command Line Tools
xcode-select --install

# Opcja 3: GitHub Desktop instaluje też Git CLI
```

### Linux (Ubuntu/Debian)
```bash
sudo apt update
sudo apt install -y git

# Najnowsza wersja (PPA):
sudo add-apt-repository ppa:git-core/ppa
sudo apt update
sudo apt install -y git
```

### Sprawdź instalację
```bash
git --version
# git version 2.45.x (lub nowsza)
```

## Konfiguracja początkowa (jednorazowa)

```bash
# Identyfikacja (POJAWIA SIĘ W KOMITACH!)
git config --global user.name "Jan Kowalski"
git config --global user.email "jan@example.com"

# Default branch name (od 2020 zalecane: main)
git config --global init.defaultBranch main

# Domyślny editor (do commit messages)
git config --global core.editor "code --wait"  # VS Code
# git config --global core.editor "vim"
# git config --global core.editor "nano"

# Pull strategy (od Git 2.27 wymagane)
git config --global pull.rebase false  # merge (default)
# git config --global pull.rebase true  # rebase

# Line endings
# Windows:
git config --global core.autocrlf true
# Mac/Linux:
git config --global core.autocrlf input

# Ulepszenia UI
git config --global color.ui auto
git config --global push.autoSetupRemote true  # od 2.37, automatic upstream

# Sprawdź konfigurację
git config --list
git config --global --list

# Edycja w editorze
git config --global -e
```

### Zaawansowana konfiguracja
```bash
# Aliases (skróty)
git config --global alias.st status
git config --global alias.co checkout
git config --global alias.br branch
git config --global alias.ci commit
git config --global alias.ll "log --oneline --graph --all --decorate"

# Po tym możesz: git st, git ll itd.

# Better diff (delta — modern diff tool)
brew install git-delta  # Mac
# Lub apt install git-delta na Linuxie
git config --global core.pager delta
git config --global delta.navigate true
git config --global delta.side-by-side true
```

### SSH keys dla GitHub/GitLab
```bash
# Wygeneruj klucz (ed25519 — modern, secure)
ssh-keygen -t ed25519 -C "jan@example.com"
# Domyślne lokalizacje:
# ~/.ssh/id_ed25519 (private — NIGDY nie udostępniaj)
# ~/.ssh/id_ed25519.pub (public — kopiuj na GitHub)

# Pokaż public key (kopiujesz to do GitHub Settings → SSH Keys)
cat ~/.ssh/id_ed25519.pub

# Test
ssh -T git@github.com
# Hi <username>! You've successfully authenticated...
```

## Modele Git — 3 obszary

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│ Working Directory│ → │  Staging Area    │ → │  Repository (.git)│
│  (twoje pliki)  │    │  (index)         │    │  (commits)        │
└─────────────────┘    └─────────────────┘    └─────────────────┘
        │  git add file        git commit
        │
        └─→ git status (zobacz co jest w którym obszarze)
```

### Status pliku
```
Untracked  — nowy plik, Git nie wie o nim
Modified   — istniejący plik, zmieniony, niesetagowany
Staged     — gotowy do commitu (po git add)
Committed  — w repozytorium (po git commit)
```

## 30 najczęstszych komend

### Setup repozytorium
```bash
# Stwórz nowe repo
git init                          # w aktualnym katalogu
git init my-project               # nowy katalog

# Klonuj istniejące
git clone https://github.com/user/repo.git
git clone git@github.com:user/repo.git           # SSH
git clone https://github.com/user/repo.git nazwa # custom folder name
git clone --depth 1 ...                          # shallow (tylko ostatni commit, szybsze)
git clone --branch dev ...                       # konkretny branch
```

### Status i diff
```bash
git status                        # co jest staged/modified/untracked
git status -s                     # short format
git status -b                     # z info o branch

git diff                          # różnice unstaged vs working
git diff --staged                 # różnice staged vs last commit
git diff --cached                 # alias dla --staged
git diff HEAD                     # różnice working vs last commit
git diff main..feature            # różnice między branchami
git diff abc123..def456           # między commitami

git diff --stat                   # podsumowanie (ile plików, ile linii)
git diff --word-diff              # word-level diff
```

### Stage i commit
```bash
git add file.txt                  # dodaj 1 plik do staging
git add file1 file2               # wiele plików
git add .                         # wszystkie zmienione w aktualnym dir
git add -A                        # WSZYSTKIE zmiany (też usunięte)
git add *.js                      # glob pattern
git add -p                        # interaktywne (patch by patch)
git add -u                        # tylko już tracked files

git restore --staged file.txt     # unstage (modern, od Git 2.23)
git reset HEAD file.txt           # unstage (legacy)

git commit -m "Add feature X"     # commit z message
git commit                        # otwiera editor
git commit -am "msg"              # add modified + commit (NIE untracked!)
git commit --amend                # popraw ostatni commit
git commit --amend --no-edit      # popraw ostatni commit BEZ zmiany message
git commit --amend -m "new msg"   # zmień message ostatniego
```

### Conventional Commits (rekomendacja)
Format: `type(scope): subject`

```bash
git commit -m "feat: add user authentication"
git commit -m "fix: handle null email in registration"
git commit -m "docs: update README installation"
git commit -m "refactor: extract validation to UserService"
git commit -m "test: add unit tests for OrderRepository"
git commit -m "chore: update dependencies"
git commit -m "perf: optimize database query in dashboard"
git commit -m "build: configure GitHub Actions for tests"
git commit -m "ci: add deployment workflow"
git commit -m "style: format code with prettier"

# Breaking change:
git commit -m "feat!: change API response format"
# lub w body: "BREAKING CHANGE: ..."
```

### Historia
```bash
git log                           # commity (wszystkie info)
git log --oneline                 # 1 linia per commit
git log --graph                   # ASCII graph
git log --oneline --graph --all   # wszystkie branche, graf
git log --decorate                # pokaż branch/tag names
git log -n 10                     # ostatnie 10
git log --since="2 weeks ago"
git log --until="2026-01-01"
git log --author="Jan"
git log --grep="bug"              # commity z "bug" w message
git log -- file.txt               # historia konkretnego pliku
git log -p file.txt               # z diffami zmian pliku
git log --follow file.txt         # historia z renames

# Best alias do .gitconfig:
git config --global alias.lg "log --oneline --graph --all --decorate"
git lg                            # potem wystarczy

# Show konkretny commit
git show abc123
git show HEAD                     # ostatni commit
git show HEAD~1                   # commit przed ostatnim
git show HEAD^                    # j.w.
git show HEAD~3                   # 3 commity przed
```

### Branche
```bash
git branch                        # lista lokalnych branchy
git branch -r                     # remote branche
git branch -a                     # wszystkie

git branch feature                # nowy branch (NIE przełącza)
git checkout feature              # przełącz na branch (legacy)
git switch feature                # modern (od Git 2.23)

git checkout -b feature           # stwórz + przełącz (legacy)
git switch -c feature             # stwórz + przełącz (modern)

git branch -d feature             # usuń (sprawdza merge)
git branch -D feature             # FORCE usuń (ostrożnie!)

git branch -m old-name new-name   # rename
git branch -m new-name            # rename aktualny

git branch --set-upstream-to=origin/main main  # ustaw upstream
```

### Merge i rebase
```bash
git merge feature                 # merge feature do aktualnego
git merge --no-ff feature         # zawsze merge commit (no fast-forward)
git merge --squash feature        # squash do 1 commit, manual commit potem

git rebase main                   # przebazuj aktualny branch na main
git rebase -i HEAD~3              # interaktywny rebase ostatnich 3 commitów

# Po conflict podczas merge/rebase:
# 1. Edytuj pliki, rozwiąż konflikty (szukaj <<<<<<< i >>>>>>>)
# 2. git add <resolved files>
# 3. git merge --continue  (lub: git rebase --continue)
# Lub: git merge --abort  (cofnij merge)
```

### Zdalne repozytoria (remote)
```bash
git remote                        # lista remotes (zazwyczaj "origin")
git remote -v                     # z URL
git remote add upstream https://...  # dodaj remote
git remote remove origin
git remote rename old new

git fetch                         # pobierz zmiany (BEZ merge)
git fetch --all                   # wszystkie remotes
git fetch origin main             # konkretny branch

git pull                          # fetch + merge
git pull --rebase                 # fetch + rebase (cleaner history)
git pull origin main

git push                          # push do upstream
git push origin feature           # push do origin/feature
git push -u origin feature        # j.w. + ustaw upstream (--set-upstream)
git push --force                  # FORCE (ostrożnie! przepisuje historię)
git push --force-with-lease       # safer force (sprawdza if remote zmienione)

git push --tags                   # wraz z tagami
git push origin --delete branch   # usuń remote branch
```

### Tags
```bash
git tag                           # lista tagów
git tag v1.0.0                    # lightweight tag
git tag -a v1.0.0 -m "Release 1.0.0"  # annotated tag (zalecany)
git tag -a v1.0.0 abc123          # tag konkretnego commita

git push origin v1.0.0            # push tag
git push --tags                   # wszystkie tagi

git tag -d v1.0.0                 # usuń lokalnie
git push origin --delete v1.0.0   # usuń remote
```

### Stash (tymczasowo odłóż zmiany)
```bash
git stash                         # zapisz zmiany na "półkę"
git stash save "WIP: feature X"   # z message
git stash list                    # lista stash
git stash show                    # ostatni stash
git stash show -p                 # z diffami

git stash pop                     # przywróć i usuń ze stash
git stash apply                   # przywróć ALE zostaw na stash
git stash apply stash@{2}         # konkretny

git stash drop                    # usuń ostatni
git stash clear                   # usuń wszystkie

git stash branch new-branch       # nowy branch z tego stash
```

### Reset i revert (cofanie zmian)
```bash
# Restore (od Git 2.23 — preferowane)
git restore file.txt              # cofnij modyfikacje (working dir)
git restore --staged file.txt     # unstage
git restore --source=HEAD~1 file  # przywróć z poprzedniego commita

# Reset (legacy ale potężny)
git reset HEAD file.txt           # unstage (== --mixed)
git reset --soft HEAD~1           # cofnij commit, zachowaj staged
git reset --mixed HEAD~1          # cofnij commit, unstage (default)
git reset --hard HEAD~1           # cofnij commit, USUŃ ZMIANY (ostrożnie!)
git reset --hard origin/main      # przywróć do remote

# Revert (bezpieczne — tworzy nowy commit cofający)
git revert HEAD                   # cofnij ostatni commit (publish-safe)
git revert abc123
```

### Cherry-pick
```bash
git cherry-pick abc123            # weź commit z innej gałęzi
git cherry-pick abc123..def456    # range
git cherry-pick --no-commit abc123  # pick bez auto-commit
```

### Bisect (binary search bug)
```bash
git bisect start
git bisect bad                    # aktualny commit ma bug
git bisect good v1.0.0           # v1.0.0 NIE miał buga
# Git automatycznie checkout middle commit
# Testuj. Potem:
git bisect good                   # ten commit OK
# lub:
git bisect bad                    # ten commit ma bug
# Powtarzaj aż Git znajdzie pierwszy bad commit
git bisect reset                  # zakończ bisect
```

### Reflog (recovery!)
```bash
# Reflog = log każdej operacji która zmieniła HEAD
# Lifesaver! Możesz przywrócić "usunięte" commity
git reflog

# Output:
# abc123 HEAD@{0}: reset: moving to HEAD~3
# def456 HEAD@{1}: commit: add feature X   ← ten commit "zniknął" po reset
# 789abc HEAD@{2}: commit: add feature Y

# Przywróć commit:
git reset --hard def456
# lub stwórz branch z tego commita:
git branch recovered-feature def456
```

### Submodules
```bash
git submodule add https://github.com/lib/repo libs/repo
git submodule init
git submodule update
git submodule update --init --recursive

git clone --recursive https://...   # klon razem z submodulami
```

### Worktrees (wiele branchy w wielu folderach)
```bash
git worktree add ../project-feature feature
# Teraz feature branch jest w ../project-feature, możesz pracować równolegle

git worktree list
git worktree remove ../project-feature
```

## .gitignore — kluczowy plik

```bash
# Plik .gitignore w root repo określa co NIE trackować

# Przykład .gitignore:
node_modules/
*.log
.env
.env.local
.DS_Store
Thumbs.db
build/
dist/
.idea/
.vscode/settings.json
*.pyc
__pycache__/
target/         # Rust, Java
*.class         # Java
.next/          # Next.js
coverage/

# Globalne ignore (per user)
git config --global core.excludesfile ~/.gitignore_global
echo ".DS_Store" >> ~/.gitignore_global
```

**Generator .gitignore:**
- gitignore.io (nowoczesny, web-based)
- github.com/github/gitignore (templates dla różnych technologii)

## Workflow przykładowy — daily

```bash
# Rano:
cd ~/projects/myapp
git pull                              # pobierz zmiany
git status                            # cokolwiek lokalnie?

# Rozpocznij feature:
git switch -c feature/user-profile

# Pracuj, zapisuj często:
git add .
git commit -m "wip: profile component"

# Pushaj branch:
git push -u origin feature/user-profile

# Inni na main, sync:
git fetch origin
git rebase origin/main                # albo merge

# Po skończeniu — pull request via GitHub UI
# lub:
gh pr create --title "Add user profile" --body "Closes #42"
```

## GitHub CLI (`gh`)

Modern alternative do clicking GitHub UI:

```bash
# Instalacja
brew install gh
# lub apt install gh

# Login
gh auth login

# Pull requests
gh pr create
gh pr list
gh pr checkout 123                # checkout PR locally
gh pr view 123
gh pr merge 123

# Issues
gh issue create
gh issue list
gh issue close 456

# Repos
gh repo create
gh repo clone user/repo
gh repo view --web                # otwórz w przeglądarce

# Releases
gh release create v1.0.0 --notes "Initial release"
```

## Conflict resolution

Gdy git merge / rebase produkuje konflikty:

```bash
git status                        # pokaże "both modified: file.txt"

# Otwórz file.txt — zobaczysz markery:
# <<<<<<< HEAD
# wersja z aktualnego brancha
# =======
# wersja z mergowanego brancha
# >>>>>>> feature

# Edit, usuń markery, zostaw czego chcesz
# Save plik

git add file.txt
git merge --continue              # lub git rebase --continue

# Jeśli chcesz anulować merge:
git merge --abort
git rebase --abort
```

### Tools do merge (3-way merge)
```bash
# Konfiguracja
git config --global merge.tool vscode
git config --global mergetool.vscode.cmd 'code --wait $MERGED'

# Użycie
git mergetool

# Inne tools: meld (Linux), KDiff3, Beyond Compare, P4Merge
```

## Najczęstsze błędy i jak naprawić

### "Commit z błędną wiadomością"
```bash
git commit --amend -m "Lepsza wiadomość"
# Jeśli już pushnięte → force push (UWAGA na shared branch!)
git push --force-with-lease
```

### "Zapomniałem dodać plik do commita"
```bash
git add forgotten-file.txt
git commit --amend --no-edit
```

### "Skomitowałem na złym branchu"
```bash
# Aktualnie jestem na main, commit miał być na feature
git branch feature                # zapamiętaj commit w feature branch
git reset --hard HEAD~1           # cofnij main
git switch feature                # przełącz, masz commit
```

### "Niechcący git reset --hard, straciłem zmiany"
```bash
git reflog                        # znajdź gdzie był HEAD przed reset
git reset --hard HEAD@{1}         # przywróć
```

### "Konflikty w pull, chcę zacząć od nowa"
```bash
git merge --abort                 # cofnij merge
# lub:
git reset --hard origin/main      # przywróć do remote (UTRATA lokalnych zmian!)
```

### ".env pushnęło się do GitHuba!"
```bash
# 1. Usuń z historii (BFG repo cleaner — pobierz z rtyley.github.io/bfg-repo-cleaner)
bfg --delete-files .env
git reflog expire --expire=now --all
git gc --prune=now --aggressive
git push --force

# 2. ROTUJ wszystkie sekrety z .env (zakładaj że są skompromitowane)

# 3. Dodaj .env do .gitignore (na przyszłość)
echo ".env" >> .gitignore
git add .gitignore
git commit -m "Add .env to gitignore"
```

### "Branch jest behind main, jak zsynchronizować"
```bash
# Opcja A: rebase (cleaner history)
git fetch origin
git rebase origin/main
git push --force-with-lease

# Opcja B: merge (zachowuje historię merge)
git fetch origin
git merge origin/main
git push
```

## Performance i large repos

```bash
# Shallow clone (tylko ostatni commit)
git clone --depth 1 https://...

# Single branch
git clone --single-branch --branch main https://...

# Partial clone (large monorepos)
git clone --filter=blob:none https://...

# Sparse checkout (tylko niektóre foldery)
git clone https://...
cd repo
git sparse-checkout init --cone
git sparse-checkout set folder1 folder2

# Git LFS (Large File Storage) — dla plików > 100 MB
git lfs install
git lfs track "*.psd"
git add .gitattributes
```

## Best practices

### Commits
- **Atomic commits** — jedna logiczna zmiana per commit
- **Conventional Commits** format
- **Imperative mood** — "Add feature" nie "Added feature"
- **First line < 72 znaki**
- **Body** dla "why" (jeśli potrzebne)

### Branches
- **main / master** — production-ready
- **develop** — integration (jeśli GitFlow)
- **feature/xyz** — nowe feature
- **fix/xyz** — bug fixes
- **release/v1.0.0** — release prep
- **hotfix/xyz** — emergency fixes

### Pull Requests
- **Small** — < 400 linii preferowane
- **Tests included**
- **Description** wyjaśniająca "why"
- **Linked issue** (Closes #123)
- **Code review obowiązkowe**
- **CI must pass** przed merge

### Co NIE robić
- ❌ Force push na shared branch (main, develop)
- ❌ Commit secretów (.env, API keys, passwords)
- ❌ Commit large binaries (use LFS)
- ❌ Mega-commity (50 plików, 1000 linii zmian)
- ❌ Vague messages ("fix", "update", "stuff")
- ❌ Mix WIP commits w main

## Cheatsheet — top 20 komend

```bash
git init                          # nowe repo
git clone <url>                   # sklonuj
git status                        # status
git add <file>                    # stage
git commit -m "msg"               # commit
git log --oneline --graph --all   # historia
git diff                          # zmiany
git branch                        # branche
git switch <branch>               # przełącz
git switch -c <branch>            # stwórz + przełącz
git merge <branch>                # merge
git pull                          # pobierz + merge
git push                          # wyślij
git stash                         # tymczasowo odłóż
git stash pop                     # przywróć
git restore <file>                # cofnij modyfikacje
git restore --staged <file>       # unstage
git reset --hard HEAD~1           # cofnij commit (UWAGA)
git reflog                        # wszystkie operacje (recovery)
git remote -v                     # remotes
```

## Następne kroki

- **Rozdział 02** — branching i merging (zaawansowane)
- **Rozdział 03** — zdalne repozytoria (GitHub, GitLab)
- **Rozdział 04** — workflow strategies (GitFlow, GitHub Flow)
- **Rozdział 05** — zaawansowane (rebase, bisect, hooks)

## Linki i zasoby

- **Pro Git book** (free, online): git-scm.com/book
- **Git documentation**: git-scm.com/docs
- **Learn Git Branching** (interactive): learngitbranching.js.org
- **GitHub Skills**: skills.github.com
- **Oh My Git!** (game): ohmygit.org
- **gitignore.io** — generator .gitignore
- **Atlassian Git tutorials**: atlassian.com/git
