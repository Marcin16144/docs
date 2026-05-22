# Linux — podstawy i komendy (z naciskiem na Ubuntu)

## Czym jest Linux?

**Linux** to rodzina open source systemów operacyjnych opartych na **kernelu Linux** (1991, Linus Torvalds). W praktyce "Linux" oznacza **dystrybucję** — kernel + zestaw narzędzi + package manager + UI.

### Najpopularniejsze dystrybucje (2026)

| Dystrybucja | Bazuje na | Use case | Package mgr |
|-------------|-----------|----------|-------------|
| **Ubuntu** ⭐ | Debian | Desktop, serwery, najszerszy support | apt |
| **Debian** | (parent) | Stabilne serwery | apt |
| **Linux Mint** | Ubuntu | Desktop user-friendly | apt |
| **Pop!_OS** | Ubuntu | Developer desktops, świetny NVIDIA | apt |
| **Fedora** | Red Hat | Bleeding-edge, dev workstation | dnf |
| **RHEL / Rocky / AlmaLinux** | Red Hat | Enterprise serwery | dnf |
| **Arch Linux** | (parent) | Power users, rolling release | pacman |
| **openSUSE** | (parent) | Enterprise alternative | zypper |
| **Alpine** | (parent) | Container base images | apk |
| **NixOS** | (parent) | Reproducible, declarative | nix |
| **Manjaro** | Arch | Friendly Arch | pacman |
| **Kali / Parrot** | Debian | Security/pentesting | apt |

**W tym rozdziale:** skupiamy się na **Ubuntu** (najpopularniejszy), ale komendy są w 95% takie same w innych dystrybucjach Debian-based (Mint, Pop!_OS).

## Wersje Ubuntu (2026)

| Wersja | Codename | Release | Wsparcie do | Status |
|--------|----------|---------|-------------|--------|
| **Ubuntu 24.04 LTS** | Noble Numbat | 04/2024 | 04/2029 (5 lat), 10 lat z Pro | ⭐ Aktualna LTS |
| **Ubuntu 24.10** | Oracular Oriole | 10/2024 | 07/2025 (9 mc) | Interim |
| **Ubuntu 25.04** | Plucky Puffin | 04/2025 | 01/2026 (9 mc) | Interim |
| **Ubuntu 25.10** | Questing Quokka | 10/2025 | 07/2026 (9 mc) | Aktualna interim |
| **Ubuntu 26.04 LTS** | (TBA) | 04/2026 | 04/2031 (5 lat) | Najnowsza LTS (planowana) |
| **Ubuntu 22.04 LTS** | Jammy Jellyfish | 04/2022 | 04/2027 | Wciąż popularna |
| **Ubuntu 20.04 LTS** | Focal Fossa | 04/2020 | 04/2025 | EOL już w 2025 |

**Reguła:** dla produkcji używaj **LTS (Long-Term Support)**, dla desktop development OK **interim** (cutting edge).

### Ubuntu Pro
- **Free dla 5 maszyn** (od 2023)
- Extended support (10 lat zamiast 5)
- Live kernel patching, kompliance (FIPS, CIS), security patches dla starszych pakietów

## Filozofia Unix

```
1. "Make each program do one thing well"
2. "Expect the output of every program to become the input to another"
3. "Design and build software to be tried early"
4. "Use tools in preference to unskilled help"
```

Konsekwencja: wiele małych narzędzi + **pipes** (`|`) = potężne kombinacje.

## Struktura systemu plików (FHS)

```
/                  ← root (NIE mylić z /root)
├── bin/           ← kluczowe komendy (cp, mv, ls...)
├── boot/          ← pliki kernela, GRUB
├── dev/           ← pliki urządzeń (/dev/sda, /dev/null)
├── etc/           ← konfiguracja systemowa
│   ├── apt/       ← konfiguracja apt
│   ├── nginx/     ← config nginx
│   └── ssh/       ← config SSH
├── home/          ← katalogi użytkowników
│   ├── alice/
│   └── bob/
├── lib/, lib64/   ← biblioteki systemowe
├── media/, mnt/   ← punkty montowania (USB, dyski)
├── opt/           ← oprogramowanie 3rd party
├── proc/          ← virtual filesystem (info o procesach)
├── root/          ← home użytkownika root
├── run/           ← pliki runtime (sockety, PID)
├── sbin/          ← komendy administracyjne (mount, fdisk)
├── srv/           ← dane serwerów (np. nginx www)
├── sys/           ← virtual filesystem (info o kernelu, sprzęcie)
├── tmp/           ← pliki tymczasowe (czyszczone)
├── usr/           ← user programs ("system tier")
│   ├── bin/       ← większość komend (np. python, vim)
│   ├── lib/       ← biblioteki
│   ├── local/     ← oprogramowanie zainstalowane lokalnie
│   └── share/     ← współdzielone dane (docs, icons)
└── var/           ← variable data
    ├── log/       ← logi systemu i aplikacji
    ├── lib/       ← stan aplikacji (databases)
    ├── cache/     ← cache (apt, browser)
    └── www/       ← domyślne pliki web (Apache, nginx)
```

## Shell — bash

**Bash** (Bourne Again SHell) to domyślny shell Ubuntu. Alternatywy: zsh (popular dla devs), fish (user-friendly), dash (lekki, /bin/sh).

```bash
# Sprawdź swój shell
echo $SHELL
# /bin/bash

# Lista zainstalowanych shelli
cat /etc/shells

# Zmień default shell
chsh -s /bin/zsh
```

## 50 najczęstszych komend

### Nawigacja (file system)

```bash
pwd                       # gdzie jestem? (Print Working Directory)
ls                        # lista plików w aktualnym katalogu
ls -la                    # długi format z ukrytymi
ls -lah                   # human-readable rozmiary
ls -ltr                   # sortowanie po time, reverse (najnowsze ostatnie)

cd /path/to/dir           # przejdź do katalogu
cd ~                      # home
cd -                      # poprzedni katalog (toggle)
cd ..                     # rodzic

tree                      # drzewo katalogów (apt install tree)
tree -L 2                 # 2 poziomy
```

### Pliki — operacje

```bash
touch file.txt            # stwórz pusty plik
mkdir myfolder            # stwórz katalog
mkdir -p a/b/c            # stwórz wraz z parents

cp src.txt dst.txt        # kopiuj plik
cp -r src/ dst/           # kopiuj katalog rekurencyjnie
cp -p ...                 # zachowaj uprawnienia/timestamps
cp -i ...                 # interaktywne (potwierdzenie overwrite)

mv old.txt new.txt        # rename / move
mv file.txt /tmp/         # przenieś do /tmp/

rm file.txt               # usuń plik
rm -r folder/             # rekurencyjnie
rm -rf folder/            # FORCE rekurencyjnie (UWAGA!)
rm -i ...                 # interaktywne

rmdir empty_folder        # usuń pusty katalog (bezpieczne)

ln -s /target /link       # symlink
ln /target /hardlink      # hard link

readlink -f /path/link    # rozwiń symlink do absolute
```

### Czytanie plików

```bash
cat file.txt              # cały plik na stdout
cat file1 file2           # konkatenacja
less file.txt             # interaktywny pager (q = quit, /search)
more file.txt             # legacy pager
head file.txt             # pierwsze 10 linii
head -n 50 file.txt       # pierwsze 50
tail file.txt             # ostatnie 10
tail -f /var/log/syslog   # follow (live updates) — KLUCZOWE dla logów
tail -n 100 -f log        # ostatnie 100 + follow
nl file.txt               # numeruj linie
wc file.txt               # word count: lines, words, chars
wc -l file.txt            # tylko linie
file file.txt             # detekcja typu pliku
stat file.txt             # szczegółowe info (size, perms, timestamps)
```

### Wyszukiwanie

```bash
find / -name "*.conf"     # znajdź wszystkie .conf
find . -type f -mtime -7  # pliki zmodyfikowane w ostatnich 7 dniach
find . -size +100M        # pliki > 100 MB
find . -type d            # tylko katalogi
find . -name "*.log" -delete  # znajdź i usuń (UWAGA!)
find . -name "*.tmp" -exec rm {} \;  # exec na każdym znalezionym

locate filename           # szybkie find (wymaga: sudo updatedb)
which python              # ścieżka komendy w PATH
whereis python            # bin + man + source paths
type python               # alias / function / file?

grep "pattern" file.txt   # wyszukaj wzorzec
grep -i "pattern" file    # case insensitive
grep -r "pattern" /etc/   # rekurencyjne
grep -n "pattern" file    # z numerami linii
grep -v "pattern" file    # invert (linie BEZ wzorca)
grep -E "regex" file      # extended regex
grep -A 3 "pattern" file  # 3 linie po match
grep -B 3 "pattern" file  # 3 linie przed
grep -C 3 "pattern" file  # context: 3 przed i 3 po

# Modern alternatywy:
ripgrep / rg "pattern"    # apt install ripgrep — szybsze niż grep
fd "pattern"              # apt install fd-find — modern find
```

### Zarządzanie pakietami (apt — Ubuntu/Debian)

```bash
sudo apt update           # aktualizuj listę dostępnych pakietów
sudo apt upgrade          # zaktualizuj zainstalowane
sudo apt full-upgrade     # upgrade z usuwaniem przestarzałych
sudo apt dist-upgrade     # j.w. (alias)

sudo apt install package  # instaluj
sudo apt install pkg1 pkg2 pkg3
sudo apt install -y pkg   # bez pytania (skrypty)

sudo apt remove pkg       # usuń (zachowaj config)
sudo apt purge pkg        # usuń całkowicie (z configiem)
sudo apt autoremove       # usuń niepotrzebne dependencies

apt search keyword        # szukaj pakietu
apt show package          # info o pakiecie
apt list --installed      # lista zainstalowanych
apt list --upgradable     # lista do upgrade

# Repozytoria
sudo add-apt-repository ppa:user/repo
sudo apt-add-repository "deb https://..."
sudo nano /etc/apt/sources.list.d/myrepo.list

# Klucze GPG (legacy /etc/apt/trusted.gpg.d/, modern: signed-by)
sudo gpg --no-default-keyring --keyring /usr/share/keyrings/repo.gpg --import key.asc

# .deb files
sudo dpkg -i package.deb
sudo dpkg -l | grep package
sudo dpkg -P package
```

### Snap, Flatpak, AppImage

```bash
# Snap (preinstalowany na Ubuntu)
snap find spotify
sudo snap install spotify
snap list
sudo snap remove spotify

# Flatpak (modern alternative, popular)
sudo apt install flatpak gnome-software-plugin-flatpak
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
flatpak install flathub com.spotify.Client

# AppImage (single file, run anywhere)
chmod +x app.AppImage
./app.AppImage
```

### Procesy

```bash
ps aux                    # wszystkie procesy
ps -ef                    # alternatywny format
ps aux | grep nginx       # filtruj
pgrep nginx               # PID procesów po nazwie
pidof nginx

top                       # interaktywny monitor (q = quit)
htop                      # ładniejszy top (apt install htop)
btop                      # nowoczesny ekstrażeczy (apt install btop)

kill PID                  # SIGTERM (graceful)
kill -9 PID               # SIGKILL (force, last resort)
kill -HUP PID             # reload config (np. nginx)
killall process_name      # zabij po nazwie
pkill -f "pattern"        # zabij gdy command line zawiera pattern

# Background / foreground
command &                 # run w tle
jobs                      # lista jobs
fg %1                     # przywróć job 1 do foreground
bg %1                     # job w tle
nohup command &           # run nawet po wylogowaniu (logs → nohup.out)
disown                    # detach od terminal

# nice / renice (priorytet)
nice -n 10 command        # niższy priorytet (10 = nice)
renice 10 -p PID

# screen / tmux (persistent sessions)
screen                    # nowa sesja
screen -r                 # reattach
tmux                      # alternative (bardziej popularna)
tmux attach
```

### systemd (services)

Systemd to **init system Ubuntu**. Zarządza usługami, boot procesem.

```bash
systemctl status nginx           # status
systemctl start nginx            # uruchom
systemctl stop nginx             # zatrzymaj
systemctl restart nginx          # restart
systemctl reload nginx           # reload config bez restartu
systemctl enable nginx           # autostart przy boot
systemctl disable nginx          # bez autostartu
systemctl is-active nginx
systemctl is-enabled nginx

systemctl list-units --type=service           # uruchomione services
systemctl list-units --type=service --all     # wszystkie services
systemctl list-unit-files                     # config files

# Logi systemd
journalctl                       # wszystkie logi
journalctl -u nginx              # tylko nginx
journalctl -u nginx -f           # follow
journalctl -u nginx -n 100       # ostatnie 100 linii
journalctl --since "1 hour ago"
journalctl --since "2026-05-01" --until "2026-05-08"
journalctl -p err                # tylko errors
journalctl --boot                # tylko z aktualnego boota
journalctl --vacuum-size=500M    # ogranicz rozmiar logów

# Tworzenie własnej service
sudo nano /etc/systemd/system/myapp.service
sudo systemctl daemon-reload
sudo systemctl enable --now myapp
```

Przykład myapp.service:
```ini
[Unit]
Description=My App
After=network.target

[Service]
Type=simple
User=myuser
WorkingDirectory=/opt/myapp
ExecStart=/usr/bin/python3 /opt/myapp/app.py
Restart=on-failure
RestartSec=5
Environment="PORT=8080"

[Install]
WantedBy=multi-user.target
```

### Użytkownicy i uprawnienia

```bash
# Tworzenie / usuwanie
sudo useradd -m -s /bin/bash alice    # -m = create home, -s = shell
sudo adduser alice                    # bardziej user-friendly (interactive)
sudo userdel -r alice                 # -r = usuń też home

# Grupy
sudo groupadd developers
sudo usermod -aG developers alice     # -a = append, -G = group
sudo gpasswd -d alice developers      # remove from group
groups alice                          # grupy użytkownika
id alice                              # UID, GID, groups

# Hasła
sudo passwd alice                     # ustaw hasło
sudo passwd -l alice                  # zablokuj account
sudo passwd -u alice                  # odblokuj
sudo chage -M 90 alice                # max 90 days password age
sudo chage -E 2026-12-31 alice        # account expiry

# sudo
sudo command                          # uruchom jako root
sudo -i                               # root shell (interactive)
sudo -u alice command                 # uruchom jako alice
sudo visudo                           # edytuj /etc/sudoers (validation)

# Uprawnienia plików
chmod 755 file        # rwx r-x r-x (owner all, group/other read+exec)
chmod 644 file        # rw- r-- r-- (typowy dla configs)
chmod +x script.sh    # dodaj execute
chmod -R 755 dir/     # rekurencyjnie

chown alice file              # zmień owner
chown alice:developers file   # owner + group
chown -R alice:dev /opt/app/

# Symboliczne (czytelniejsze)
chmod u+x file        # user + execute
chmod g-w file        # group - write
chmod o=r file        # other = read only
chmod a+rwx file      # all + read/write/execute

# umask (default permissions)
umask                 # pokaż aktualny
umask 022             # ustaw (typical: 022 = files 644, dirs 755)

# Special bits
chmod u+s file        # SUID (run as owner)
chmod g+s file        # SGID
chmod +t /tmp         # sticky bit (only owner can delete)

# ACL (Access Control Lists) — bardziej granularne
sudo apt install acl
setfacl -m u:bob:rwx file
getfacl file
```

### Sieć

```bash
# Adresy IP
ip a                              # wszystkie interfaces
ip addr show eth0
ip route                          # routing table
ip link                           # interfaces
hostname -I                       # IP adresy hosta

# Modern (nowy ip vs legacy ifconfig)
# ifconfig już deprecated w Ubuntu, używaj ip

# Nasłuchujące porty
ss -tulpn                         # TCP/UDP listening + processes (modern)
sudo ss -tulpn                    # z PID

# DNS
dig example.com
dig +short example.com
dig MX example.com
nslookup example.com
host example.com

# Test connectivity
ping example.com
ping -c 4 example.com             # tylko 4 pings
traceroute example.com            # apt install traceroute
mtr example.com                   # combined ping + traceroute (apt install mtr)

# Pobieranie
wget https://example.com/file.tar.gz
wget -c file.tar.gz               # continue (resume)
wget -O myname.tar file.tar.gz    # rename
curl https://api.example.com/users
curl -X POST -d '{"key":"val"}' -H "Content-Type: application/json" https://api/...
curl -O url                       # zapisz pod oryginalną nazwą
curl -L url                       # follow redirects
curl -I url                       # tylko headers (HEAD)

# SSH
ssh user@host
ssh -i key.pem user@host          # użyj klucza
ssh -p 2222 user@host             # custom port
ssh-keygen -t ed25519             # generuj parę kluczy
ssh-copy-id user@host             # skopiuj public key

# SCP / rsync (kopiowanie)
scp file.txt user@host:/path/
scp -r dir/ user@host:/path/
rsync -avz src/ user@host:/dst/   # synchronizuj (preferowane)
rsync --delete src/ dst/          # usuwa pliki które nie istnieją w src

# Firewall (UFW — uncomplicated firewall, default w Ubuntu)
sudo ufw status
sudo ufw enable
sudo ufw allow 22/tcp
sudo ufw allow ssh                # alias
sudo ufw allow from 192.168.1.0/24
sudo ufw deny 8080/tcp
sudo ufw delete allow 8080/tcp
```

### Disk i pliki

```bash
df -h                     # disk free (human readable)
df -i                     # inodes
du -sh /var/log           # disk usage tego katalogu
du -sh /var/log/*         # rozmiary subkatalogów
du -h --max-depth=1       # tylko 1 poziom
ncdu                      # interactive du (apt install ncdu)

free -h                   # pamięć (RAM, swap)
free -h -s 2              # refresh co 2 sekundy

uname -a                  # info o kernelu
lsb_release -a            # info o dystrybucji
hostnamectl               # nazwa hosta i info

# Mount
mount                     # zamontowane filesystems
sudo mount /dev/sdb1 /mnt/usb
sudo umount /mnt/usb
lsblk                     # block devices
lsblk -f                  # z UUID i typami filesystem

# Permanent mounts: /etc/fstab
# UUID=xxx /mnt/data ext4 defaults 0 2

# Disk operations (UWAGA, destructive!)
fdisk /dev/sdb            # partition tool (interactive)
mkfs.ext4 /dev/sdb1       # format na ext4
mkfs.xfs /dev/sdb1        # format na xfs
fsck /dev/sdb1            # check filesystem
parted /dev/sdb           # nowoczesny partition tool

# Swap
swapon                    # status
sudo swapoff -a           # wyłącz
sudo dd if=/dev/zero of=/swapfile bs=1M count=4096
sudo mkswap /swapfile
sudo swapon /swapfile
```

### Archiwa i kompresja

```bash
# tar
tar -czvf archive.tar.gz folder/      # gzip create verbose file
tar -cjvf archive.tar.bz2 folder/     # bzip2 (lepsze, wolniejsze)
tar -cJvf archive.tar.xz folder/      # xz (najlepsze, najwolniejsze)
tar -xzvf archive.tar.gz              # extract
tar -xvf archive.tar -C /tmp/         # extract do /tmp/
tar -tzvf archive.tar.gz              # list contents

# zip / unzip
zip -r archive.zip folder/
unzip archive.zip
unzip -d /target archive.zip

# 7z (apt install p7zip-full)
7z a archive.7z folder/
7z x archive.7z

# Modern: zstd (od Ubuntu 22.04+)
zstd file.txt
zstd -d file.txt.zst
tar -I zstd -cf archive.tar.zst folder/
```

### Tekst — manipulacja

```bash
# sed (Stream Editor)
sed 's/old/new/' file.txt              # replace pierwszy match per linia
sed 's/old/new/g' file.txt             # global (wszystkie)
sed -i 's/old/new/g' file.txt          # in-place edit
sed -n '5,10p' file.txt                # tylko linie 5-10
sed '/^#/d' file.txt                   # usuń komentarze (linie zaczynające od #)

# awk
awk '{print $1}' file                  # pierwsza kolumna
awk -F: '{print $1}' /etc/passwd       # delimiter ":"
awk '$3 > 100 {print $0}' file         # gdzie 3rd col > 100
awk '{sum+=$1} END {print sum}'        # suma kolumny 1

# cut
cut -d: -f1 /etc/passwd                # 1st col, delimiter ":"
cut -c1-10 file                        # pierwsze 10 znaków

# sort i uniq
sort file.txt                          # alfabetycznie
sort -n file.txt                       # numerycznie
sort -r file.txt                       # reverse
sort -k 2 file.txt                     # po kolumnie 2
sort file.txt | uniq                   # unique (musi być sorted!)
sort file.txt | uniq -c | sort -rn     # count + sort by frequency

# tr (translate)
echo "hello" | tr 'a-z' 'A-Z'         # uppercase: HELLO
cat file | tr -d '\r'                 # usuń \r (Windows line endings)
echo "abc 123" | tr -s ' '            # squeeze multiple spaces

# Pipes — łączenie:
cat /var/log/syslog | grep ERROR | head -20
ps aux | sort -k 3 -nr | head -5      # top 5 procesów po CPU
ls -la | awk '{sum+=$5} END {print sum}'  # suma rozmiarów
```

### Zmienne środowiskowe

```bash
echo $HOME                # /home/user
echo $PATH                # ścieżki dla komend
echo $USER, $SHELL, $PWD

# Set / export
export MY_VAR="value"     # export do child processes
echo $MY_VAR

# Persistent (per user):
echo 'export MY_VAR="value"' >> ~/.bashrc
source ~/.bashrc          # reload

# Persistent system-wide:
echo 'export MY_VAR="value"' | sudo tee -a /etc/environment

# Lista wszystkich
env
printenv

# Unset
unset MY_VAR
```

### History

```bash
history                   # lista poprzednich komend
history | grep apt        # filtruj
!42                       # uruchom komendę nr 42 z history
!!                        # ostatnia komenda (sudo !! = sudo + ostatnia)
!apt                      # ostatnia zaczynająca się od apt
^old^new                  # popraw typo w ostatniej komendzie

# Skrót: Ctrl+R = reverse search w history
```

### Skróty klawiaturowe (bash)

| Klawisz | Co robi |
|---------|---------|
| `Ctrl+C` | przerwij komendę |
| `Ctrl+D` | EOF / wyloguj |
| `Ctrl+Z` | zatrzymaj proces (potem `bg` lub `fg`) |
| `Ctrl+L` | clear screen (jak `clear`) |
| `Ctrl+R` | reverse search history |
| `Ctrl+A` | początek linii |
| `Ctrl+E` | koniec linii |
| `Ctrl+U` | usuń od kursora do początku |
| `Ctrl+K` | usuń od kursora do końca |
| `Ctrl+W` | usuń słowo wstecz |
| `Alt+.` | wstaw ostatni argument poprzedniej komendy |
| `Tab` | autocomplete |
| `Tab Tab` | pokaż wszystkie completions |

## Konfiguracja środowiska developerskiego (Ubuntu 24.04)

### Krok 1: Update systemu
```bash
sudo apt update && sudo apt upgrade -y
sudo apt install -y build-essential curl wget git vim htop tree unzip
```

### Krok 2: Git config
```bash
git config --global user.name "Your Name"
git config --global user.email "you@example.com"
git config --global init.defaultBranch main
git config --global pull.rebase false
```

### Krok 3: SSH keys
```bash
ssh-keygen -t ed25519 -C "you@example.com"
cat ~/.ssh/id_ed25519.pub  # dodaj do GitHub/GitLab
```

### Krok 4: Languages
```bash
# Node.js (via fnm — modern alternative do nvm)
curl -fsSL https://fnm.vercel.app/install | bash
source ~/.bashrc
fnm install --lts
fnm use lts-latest

# Python (z pyenv lub uv)
curl -LsSf https://astral.sh/uv/install.sh | sh  # uv (super fast)

# Rust
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh

# Go (via apt lub binary)
sudo apt install -y golang-go
```

### Krok 5: Docker
```bash
# Patrz docs/docker/04-docker-linux.md dla pełnych instrukcji
curl -fsSL https://get.docker.com | sh
sudo usermod -aG docker $USER
newgrp docker
```

### Krok 6: VS Code
```bash
sudo apt install -y software-properties-common apt-transport-https wget
wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > microsoft.gpg
sudo install -o root -g root -m 644 microsoft.gpg /etc/apt/trusted.gpg.d/
sudo sh -c 'echo "deb [arch=amd64] https://packages.microsoft.com/repos/vscode stable main" > /etc/apt/sources.list.d/vscode.list'
sudo apt update
sudo apt install code
```

### Krok 7: Modern terminal tools
```bash
# Better ls (eza), cat (bat), find (fd), grep (rg), du (dust)
sudo apt install -y bat fd-find ripgrep
cargo install eza dust  # via Rust

# Modern shell (zsh + oh-my-zsh)
sudo apt install zsh
sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# fzf (fuzzy finder)
sudo apt install fzf

# zoxide (smart cd)
curl -sSfL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh
```

## Cheatsheet — najczęstsze potrzeby

### "Sprawdź co zajmuje miejsce"
```bash
sudo du -sh /* 2>/dev/null | sort -rh | head -10
ncdu /                    # interactive
```

### "Co używa portu 8080"
```bash
sudo ss -tulpn | grep 8080
sudo lsof -i :8080
```

### "Co zajmuje CPU/RAM"
```bash
top
htop
ps aux --sort=-%cpu | head -10
ps aux --sort=-%mem | head -10
```

### "Aktualizuj wszystko"
```bash
sudo apt update && sudo apt upgrade -y && sudo apt autoremove -y
```

### "Service nie startuje, sprawdź"
```bash
systemctl status myservice
journalctl -u myservice -n 50
journalctl -u myservice -f
```

### "Jak wyciąć błędy z log"
```bash
grep -i "error\|fail\|warn" /var/log/syslog | tail -50
journalctl -p err --since "1 hour ago"
```

### "Find files modified in last hour"
```bash
find /var/log -mmin -60 -type f
```

### "Disk full, gdzie szukać?"
```bash
sudo du -sh /var/* | sort -rh
sudo journalctl --vacuum-size=200M    # zmniejsz logi
sudo apt autoremove
sudo apt clean                        # usuń cache pakietów
docker system prune -a                # jeśli docker
```

### "Reset hasła użytkownika"
```bash
sudo passwd alice
```

### "Co zostało zainstalowane ostatnio"
```bash
grep " install " /var/log/dpkg.log | tail -20
```

### "Reboot / shutdown"
```bash
sudo reboot                    # reboot now
sudo shutdown -r +5            # reboot za 5 min
sudo shutdown -h now           # halt now
sudo shutdown -c               # cancel scheduled
```

## Edytory tekstu

### nano (najprostszy)
```bash
nano file.txt
# Ctrl+O = save (write Out), Ctrl+X = exit
# Ctrl+W = search
# Ctrl+K = cut line, Ctrl+U = paste
```

### vim / vi (default w niektórych distros)
```bash
vim file.txt
# i = insert mode, Esc = command mode
# :w = save, :q = quit, :wq = save+quit, :q! = quit bez save
# /pattern = search, n = next match
# dd = usuń linię, yy = copy, p = paste
# :%s/old/new/g = replace all
```

### micro (modern alternative)
```bash
sudo apt install micro
micro file.txt
# Ctrl+S = save, Ctrl+Q = quit (jak nowoczesny editor!)
```

## Bezpieczeństwo — quick wins

```bash
# 1. Update regularnie
sudo apt update && sudo apt upgrade

# 2. Konfiguracja SSH (zabezpiecz!)
sudo nano /etc/ssh/sshd_config
# - PermitRootLogin no
# - PasswordAuthentication no (tylko klucze!)
# - Port 2222 (nie 22, less brute force)
sudo systemctl restart sshd

# 3. Firewall
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow 22/tcp
sudo ufw enable

# 4. Fail2ban (anti brute-force)
sudo apt install fail2ban
sudo systemctl enable --now fail2ban

# 5. Automatic security updates
sudo apt install unattended-upgrades
sudo dpkg-reconfigure -plow unattended-upgrades
```

## Troubleshooting tips

### "Cannot allocate memory"
```bash
free -h                              # check RAM
sudo dmesg | grep -i "out of memory" # OOM killer activations
```

### "No space left on device"
```bash
df -h                                # which disk full
df -i                                # inodes (could be exhausted nawet z miejscem)
sudo du -sh /var/* 2>/dev/null | sort -rh
```

### "Permission denied"
```bash
ls -la file                          # check perms i owner
namei -l /path/to/file               # check perms na całej ścieżce
getfacl file                         # check ACL
```

### "Process won't die"
```bash
ps aux | grep process
kill PID                             # graceful first
sleep 5
kill -9 PID                          # force jeśli wciąż żyje
```

### "Network problem"
```bash
ip a                                 # interfaces up?
ping 8.8.8.8                         # internet OK (without DNS)
ping google.com                      # DNS OK
sudo systemctl restart NetworkManager
```

## Następne kroki

- **Rozdział 02** — zarządzanie pakietami (apt, snap, flatpak)
- **Rozdział 03** — użytkownicy i uprawnienia (zaawansowane)
- **Rozdział 04** — procesy i zasoby (systemd głębiej, monitoring)
- **Rozdział 05** — sieć i firewall
- **Rozdział 06** — bash scripting

## Linki i zasoby

- **Ubuntu Documentation**: help.ubuntu.com
- **DigitalOcean tutorials**: digitalocean.com/community
- **Linux Journey** (linuxjourney.com) — interactive tutorial
- **The Linux Command Line** (linuxcommand.org) — darmowa książka
- **TLDR pages** (tldr.sh) — `tldr command` zamiast `man` (krótsze, z przykładami)
- **explainshell.com** — wkleisz komendę, pokaże co każda część robi
