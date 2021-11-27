#!/bin/sh
Infon()
{
 printf "\033[1;32m$@\033[0m"
}
Info()
{
 Infon "$@\n"
}
Error()
{
 printf "\033[1;31m$@\033[0m\n"
}
Error_n()
{
 Error "$@"
}
Error_s()
{
	Error "${red}=================================================================================${reset}"
}
log_s()
{
	Info "${green}================================================================================${reset}"
}
cp_s ()
{
	Info "${green}================================${white}VipAdmin.Club${green}===================================${reset}"
}
log_n()
{
 Info "$@"
}
log_t()
{
 log_s
 Info "- - - $@"
 log_s
}
log_tt()
{
 Info "- - - $@"
 log_s
}


RED=$(tput setaf 1)
red=$(tput setaf 1)
green=$(tput setaf 2)
yellow=$(tput setaf 3)
white=$(tput setaf 7)
reset=$(tput sgr0)
toend=$(tput hpa $(tput cols))$(tput cub 6)
YELLOW=$(tput setaf 3)
BLUE=$(tput setaf 4)
MAGENTA=$(tput setaf 5)
LIME_YELLOW=$(tput setaf 190)
CYAN=$(tput setaf 6)
VER=`cat /etc/issue.net | awk '{print $1$3}'`
OS=$(lsb_release -s -i -c -r | xargs echo |sed 's; ;-;g' | grep Ubuntu)
IP_SERV=$(echo "${SSH_CONNECTION}" | awk '{print $3}')

install_panel()
{
	clear
	if [ $VER = "Debian9" ]; then
		read -p "${white}Пожалуйста, введите домен или IP:${reset}" DOMAIN
		log_n "${BLUE}Adding Repo"
		echo "deb http://deb.debian.org/debian stretch main" > /etc/apt/sources.list
		echo "deb-src http://deb.debian.org/debian stretch main" >> /etc/apt/sources.list
		echo "deb http://security.debian.org/debian-security stretch/updates main" >> /etc/apt/sources.list
		echo "deb-src http://security.debian.org/debian-security stretch/updates main" >> /etc/apt/sources.list
		echo "deb http://deb.debian.org/debian stretch-updates main" >> /etc/apt/sources.list
		echo "deb-src http://deb.debian.org/debian stretch-updates main" >> /etc/apt/sources.list
		if [ $? -eq 0 ]; then
			echo "${green}[SUCCESS]"
			tput sgr0
		else
			echo "${red}[ERROR]"
			tput sgr0
			exit
		fi
		log_n "${BLUE}Updating packages"
		apt-get update > /dev/null 2>&1
		if [ $? -eq 0 ]; then
			echo "${green}[SUCCESS]"
			tput sgr0
		else
			echo "${red}[ERROR]"
			tput sgr0
			exit
		fi
		log_n "${BLUE}Instaling Packages"
		apt install -y pwgen apache2 php7.0 php7.0-gd php7.0-mysql php7.0-ssh2 mariadb-server unzip htop sudo curl > /dev/null 2>&1
		MYPASS=$(pwgen -cns -1 16) > /dev/null 2>&1
		CRONTOKE=$(pwgen -cns -1 14) > /dev/null 2>&1
		mysql -e "GRANT ALL ON *.* TO 'admin'@'localhost' IDENTIFIED BY '$MYPASS' WITH GRANT OPTION" > /dev/null 2>&1
		mysql -e "FLUSH PRIVILEGES" > /dev/null 2>&1
		if [ $? -eq 0 ]; then
			echo "${green}[SUCCESS]"
			tput sgr0
		else
			echo "${red}[ERROR]"
			tput sgr0
			exit
		fi
		log_n "${BLUE}Instaling PhpMyAdmin"
		echo "phpmyadmin phpmyadmin/dbconfig-install boolean true" | debconf-set-selections > /dev/null 2>&1
		echo "phpmyadmin phpmyadmin/mysql/admin-user string admin" | debconf-set-selections > /dev/null 2>&1
		echo "phpmyadmin phpmyadmin/mysql/admin-pass password $MYPASS" | debconf-set-selections > /dev/null 2>&1
		echo "phpmyadmin phpmyadmin/mysql/app-pass password $MYPASS" |debconf-set-selections > /dev/null 2>&1
		echo "phpmyadmin phpmyadmin/app-password-confirm password $MYPASS" | debconf-set-selections > /dev/null 2>&1
		echo 'phpmyadmin phpmyadmin/reconfigure-webserver multiselect apache2' | debconf-set-selections > /dev/null 2>&1
		apt-get install -y phpmyadmin > /dev/null 2>&1
		if [ $? -eq 0 ]; then
			echo "${green}[SUCCESS]"
			tput sgr0
		else
			echo "${red}[ERROR]"
			tput sgr0
			exit
		fi
		log_n "${BLUE}Setting Apache2 and MariaDB"
		cd /etc/apache2/sites-available/
		touch panel.conf
		FILE='panel.conf'
			echo "<VirtualHost *:80>">>$FILE
			echo "ServerAdmin anonim.gosmile@gmail.com">>$FILE
			echo "ServerName $DOMAIN">>$FILE
			echo "DocumentRoot /var/www">>$FILE
			echo "<Directory /var/www/>">>$FILE
			echo "Options Indexes FollowSymLinks">>$FILE
			echo "AllowOverride All">>$FILE
			echo "Require all granted">>$FILE
			echo "</Directory>">>$FILE
			echo "ErrorLog ${APACHE_LOG_DIR}/error.log">>$FILE
			echo "CustomLog ${APACHE_LOG_DIR}/access.log combined">>$FILE
			echo "</VirtualHost>">>$FILE
		cd 
		a2ensite panel > /dev/null 2>&1
		a2dissite 000-default > /dev/null 2>&1
		a2enmod rewrite > /dev/null 2>&1
		echo "Europe/Moscow" > /etc/timezone > /dev/null 2>&1
		sed -i 's/short_open_tag = Off/short_open_tag = On/g' /etc/php/7.0/apache2/php.ini > /dev/null 2>&1
		sed -i "s/upload_max_filesize = 2M/upload_max_filesize = 90M/g" /etc/php/7.0/apache2/php.ini > /dev/null 2>&1
		sed -i "s/post_max_size = 8M/post_max_size = 360M/g" /etc/php/7.0/apache2/php.ini > /dev/null 2>&1
		sed -i 's/127.0.0.1/0.0.0.0/g' /etc/mysql/mariadb.conf.d/50-server.cnf > /dev/null 2>&1
		sed -i 's/#max_connections        = 100/max_connections        = 1000/g' /etc/mysql/mariadb.conf.d/50-server.cnf > /dev/null 2>&1
		service apache2 restart > /dev/null 2>&1
		service mysql restart > /dev/null 2>&1
		if [ $? -eq 0 ]; then
			echo "${green}[SUCCESS]"
			tput sgr0
		else
			echo "${red}[ERROR]"
			tput sgr0
			exit
		fi
		log_n "${BLUE}Setting Cronrab"
		(crontab -l ; echo "0 0 * * * curl http://$DOMAIN/main/cron/index?token=$CRONTOKE") 2>&1 | grep -v "no crontab" | sort | uniq | crontab -
		(crontab -l ; echo "*/1 * * * * curl http://$DOMAIN/main/cron/gameServers?token=$CRONTOKE") 2>&1 | grep -v "no crontab" | sort | uniq | crontab -
		(crontab -l ; echo "*/1 * * * * curl http://$DOMAIN/main/cron/tasks?token=$CRONTOKE") 2>&1 | grep -v "no crontab" | sort | uniq | crontab -
		(crontab -l ; echo "0 */10 * * * curl http://$DOMAIN/main/cron/serverReloader?token=$CRONTOKE") 2>&1 | grep -v "no crontab" | sort | uniq | crontab -
		(crontab -l ; echo "*/30 * * * * curl http://$DOMAIN/main/cron/stopServers?token=$CRONTOKE") 2>&1 | grep -v "no crontab" | sort | uniq | crontab -
		(crontab -l ; echo "*/30 * * * * curl http://$DOMAIN/main/cron/stopServersQuery?token=$CRONTOKE") 2>&1 | grep -v "no crontab" | sort | uniq | crontab -
		(crontab -l ; echo "* */1 * * * curl http://$DOMAIN/main/cron/updateStats?token=$CRONTOKE") 2>&1 | grep -v "no crontab" | sort | uniq | crontab -
		(crontab -l ; echo "* */1 * * * curl http://$DOMAIN/main/cron/updateStatsLocations?token=$CRONTOKE") 2>&1 | grep -v "no crontab" | sort | uniq | crontab -
		(crontab -l ; echo "0 * */7 * * curl http://$DOMAIN/main/cron/clearLogs?token=$CRONTOKE") 2>&1 | grep -v "no crontab" | sort | uniq | crontab -
		service cron restart > /dev/null 2>&1
		if [ $? -eq 0 ]; then
			echo "${green}[SUCCESS]"
			tput sgr0
		else
			echo "${red}[ERROR]"
			tput sgr0
			exit
		fi
		log_n "${BLUE}Download Panel"
		cd / > /dev/null 2>&1
		wget https://vipadmin.club/KJ2398D/hostinpl5_6/hostinpl56.zip > /dev/null 2>&1
		if [ $? -eq 0 ]; then
			echo "${green}[SUCCESS]"
			tput sgr0
		else
			echo "${red}[ERROR]"
			tput sgr0
			exit
		fi
		log_n "${BLUE}Unpacking Panel"
		unzip hostinpl56.zip -d /var/www/ > /dev/null 2>&1
		rm hostinpl56.zip > /dev/null 2>&1
		cd > /dev/null 2>&1
		rm -Rfv /var/www/html > /dev/null 2>&1
		if [ $? -eq 0 ]; then
			echo "${green}[SUCCESS]"
			tput sgr0
		else
			echo "${red}[ERROR]"
			tput sgr0
			exit
		fi
		log_n "${BLUE}Setting Config"
		sed -i "s/parol/${MYPASS}/g" /var/www/application/config.php
		sed -i "s/domen.ru/${DOMAIN}/g" /var/www/application/config.php
		sed -i "s/xtwcklwhw222a/${CRONTOKE}/g" /var/www/application/config.php
		if [ $? -eq 0 ]; then
			echo "${green}[SUCCESS]"
			tput sgr0
		else
			echo "${red}[ERROR]"
			tput sgr0
			exit
		fi
		log_n "${BLUE}Creating and Upload Database"
		mkdir /var/lib/mysql/hostin > /dev/null 2>&1
		chown -R mysql:mysql /var/lib/mysql/hostin > /dev/null 2>&1
		mysql hostin < /var/www/hostinpl.sql > /dev/null 2>&1
		rm -rf /var/www/hostinpl.sql > /dev/null 2>&1
		if [ $? -eq 0 ]; then
			echo "${green}[SUCCESS]"
			tput sgr0
		else
			echo "${red}[ERROR]"
			tput sgr0
			exit
		fi
		log_n "${BLUE}Issuing rights"
		chown -R www-data:www-data /var/www
		chmod -R 770 /var/www
		chmod 777 /var/www/tmp
		chmod 777 /var/www/tmp/avatar
		chmod 777 /var/www/tmp/mods
		chmod 777 /var/www/tmp/tickets_img
		if [ $? -eq 0 ]; then
			echo "${green}[SUCCESS]"
			tput sgr0
		else
			echo "${red}[ERROR]"
			tput sgr0
			exit
		fi
		log_n "================== Установка HOSTINPL 5.6 успешно завершена =================="
		Error_n "${green}Адрес: ${white}http://$DOMAIN"
		Error_n "${green}Адрес phpmyadmin: ${white}http://$DOMAIN/phpmyadmin"
		Error_n "${green}Данные для входа в phpmyadmin (база панели):"
		Error_n "${green}Пользователь: ${white}admin"
		Error_n "${green}Пароль: ${white}$MYPASS"
		Error_n "${green}Мониторинг нагрузки сервера: ${white}htop"
		Error_n "${green}Пропишите ключ сайта и секретный ключ от рекапчи в конфигурации панели."
		log_n "=============================== vipadmin.club ==============================="
		Info
		log_tt "${white}Добро пожаловать в установочное меню ${BLUE}HOSTINPL 5.6"
		Info "- ${white}1 ${green}- ${white}Подключить файл подкачки"
		Info "- ${white}2 ${green}- ${white}Выход в главное меню"
		Info "- ${white}0 ${green}- ${white}Выход из установщика"
		log_s
		Info
		read -p "Пожалуйста, введите пункт меню: " case
		case $case in
		  1) install_swap;;
		  2) menu;;
		  0) exit;;
		esac
	else
		Info
		log_tt "${white}К сожалению, настройка панели возможна только на OS Debian 9"
		Info "- ${white}0 ${green}- ${white}Выход"
		log_s
		Info
		read -p "Пожалуйста, введите пункт меню: " case
		case $case in
		  0) exit;;
		esac
	fi
}
		
install_location()
{
	clear
	if [ $VER = "Debian9" ]; then
		log_n "${BLUE}Adding Repo"
		echo "deb http://deb.debian.org/debian stretch main" > /etc/apt/sources.list
		echo "deb-src http://deb.debian.org/debian stretch main" >> /etc/apt/sources.list
		echo "deb http://security.debian.org/debian-security stretch/updates main" >> /etc/apt/sources.list
		echo "deb-src http://security.debian.org/debian-security stretch/updates main" >> /etc/apt/sources.list
		echo "deb http://deb.debian.org/debian stretch-updates main" >> /etc/apt/sources.list
		echo "deb-src http://deb.debian.org/debian stretch-updates main" >> /etc/apt/sources.list
		if [ $? -eq 0 ]; then
			echo "${green}[SUCCESS]"
			tput sgr0
		else
			echo "${red}[ERROR]"
			tput sgr0
			exit
		fi
		groupadd gameservers > /dev/null 2>&1
		log_n "${BLUE}Updating packages"
		apt-get update > /dev/null 2>&1
		if [ $? -eq 0 ]; then
			echo "${green}[SUCCESS]"
			tput sgr0
		else
			echo "${red}[ERROR]"
			tput sgr0
			exit
		fi
		log_n "${BLUE}Instaling packages"
		apt-get install -y curl pwgen sudo unzip openssh-server apache2 php7.0 mariadb-server > /dev/null 2>&1
		MYPASS=$(pwgen -cns -1 16) > /dev/null 2>&1
		mysql -e "GRANT ALL ON *.* TO 'admin'@'localhost' IDENTIFIED BY '$MYPASS' WITH GRANT OPTION" > /dev/null 2>&1
		mysql -e "FLUSH PRIVILEGES" > /dev/null 2>&1
		if [ $? -eq 0 ]; then
			echo "${green}[SUCCESS]"
			tput sgr0
		else
			echo "${red}[ERROR]"
			tput sgr0
			exit
		fi
		log_n "${BLUE}Instaling PhpMyAdmin"
		echo "phpmyadmin phpmyadmin/dbconfig-install boolean true" | debconf-set-selections > /dev/null 2>&1
		echo "phpmyadmin phpmyadmin/mysql/admin-user string admin" | debconf-set-selections > /dev/null 2>&1
		echo "phpmyadmin phpmyadmin/mysql/admin-pass password $MYPASS" | debconf-set-selections > /dev/null 2>&1
		echo "phpmyadmin phpmyadmin/mysql/app-pass password $MYPASS" |debconf-set-selections > /dev/null 2>&1
		echo "phpmyadmin phpmyadmin/app-password-confirm password $MYPASS" | debconf-set-selections > /dev/null 2>&1
		echo 'phpmyadmin phpmyadmin/reconfigure-webserver multiselect apache2' | debconf-set-selections > /dev/null 2>&1
		apt-get install -y phpmyadmin > /dev/null 2>&1
		if [ $? -eq 0 ]; then
			echo "${green}[SUCCESS]"
			tput sgr0
		else
			echo "${red}[ERROR]"
			tput sgr0
			exit
		fi
		log_n "${BLUE}Setting Apache2 and MariaDB"
		cd /etc/apache2/sites-available/
		touch phpmyadmin.conf
		FILE='phpmyadmin.conf'
			echo "<VirtualHost *:80>">>$FILE
			echo "ServerAdmin anonim.gosmile@gmail.com">>$FILE
			echo "ServerName $IP_SERV">>$FILE
			echo "DocumentRoot /usr/share/phpmyadmin">>$FILE
			echo "<Directory /usr/share/phpmyadmin/>">>$FILE
			echo "Options Indexes FollowSymLinks">>$FILE
			echo "AllowOverride All">>$FILE
			echo "Require all granted">>$FILE
			echo "</Directory>">>$FILE
			echo "ErrorLog ${APACHE_LOG_DIR}/error.log">>$FILE
			echo "CustomLog ${APACHE_LOG_DIR}/access.log combined">>$FILE
			echo "</VirtualHost>">>$FILE
		cd 
		a2ensite phpmyadmin > /dev/null 2>&1
		a2dissite 000-default > /dev/null 2>&1
		a2enmod rewrite > /dev/null 2>&1
		echo "Europe/Moscow" > /etc/timezone > /dev/null 2>&1
		sed -i 's/short_open_tag = Off/short_open_tag = On/g' /etc/php/7.0/apache2/php.ini > /dev/null 2>&1
		sed -i "s/upload_max_filesize = 2M/upload_max_filesize = 90M/g" /etc/php/7.0/apache2/php.ini > /dev/null 2>&1
		sed -i "s/post_max_size = 8M/post_max_size = 360M/g" /etc/php/7.0/apache2/php.ini > /dev/null 2>&1
		sed -i 's/127.0.0.1/0.0.0.0/g' /etc/mysql/mariadb.conf.d/50-server.cnf > /dev/null 2>&1
		sed -i 's/#max_connections        = 100/max_connections        = 1000/g' /etc/mysql/mariadb.conf.d/50-server.cnf > /dev/null 2>&1
		service apache2 restart > /dev/null 2>&1
		service mysql restart > /dev/null 2>&1
		if [ $? -eq 0 ]; then
			echo "${green}[SUCCESS]"
			tput sgr0
		else
			echo "${red}[ERROR]"
			tput sgr0
			exit
		fi
		log_n "${BLUE}Create folder"
		mkdir /home/cp > /dev/null 2>&1
		mkdir /home/cp/backups > /dev/null 2>&1
		mkdir /home/cp/gameservers > /dev/null 2>&1
		mkdir /home/cp/gameservers/files > /dev/null 2>&1
		if [ $? -eq 0 ]; then
			echo "${green}[SUCCESS]"
			tput sgr0
		else
			echo "${red}[ERROR]"
			tput sgr0
			exit
		fi
		log_n "${BLUE}Issuing rights"
		cd > /dev/null 2>&1
		chown -R root /home/ > /dev/null 2>&1
		chmod -R 755 /home/ > /dev/null 2>&1
		chmod 700 /home/cp/backups > /dev/null 2>&1
		if [ $? -eq 0 ]; then
			echo "${green}[SUCCESS]"
			tput sgr0
		else
			echo "${red}[ERROR]"
			tput sgr0
			exit
		fi
		echo "Europe/Moscow" > /etc/timezone > /dev/null 2>&1
		log_n "${BLUE}Setting SSH"
		sudo sh -c "echo '' >> /etc/ssh/sshd_config" > /dev/null 2>&1
		sudo sh -c "echo 'DenyGroups gameservers' >> /etc/ssh/sshd_config" > /dev/null 2>&1
		service ssh restart > /dev/null 2>&1
		if [ $? -eq 0 ]; then
			echo "${green}[SUCCESS]"
			tput sgr0
		else
			echo "${red}[ERROR]"
			tput sgr0
			exit
		fi
		log_n "${BLUE}Instaling FTP Service"
		apt-get install -y proftpd > /dev/null 2>&1
		sudo sh -c "echo 'DefaultRoot ~' >> /etc/proftpd/proftpd.conf" > /dev/null 2>&1
		sudo sh -c "echo 'RequireValidShell off' >> /etc/proftpd/proftpd.conf" > /dev/null 2>&1
		service proftpd restart > /dev/null 2>&1
		if [ $? -eq 0 ]; then
			echo "${green}[SUCCESS]"
			tput sgr0
		else
			echo "${red}[ERROR]"
			tput sgr0
			exit
		fi
		log_n "${BLUE}Instaling HTOP"
		apt-get install -y htop > /dev/null 2>&1
		if [ $? -eq 0 ]; then
			echo "${green}[SUCCESS]"
			tput sgr0
		else
			echo "${red}[ERROR]"
			tput sgr0
			exit
		fi
		log_n "${BLUE}Instaling Docker"
		log_n "${white}Step: 1/5"
		apt-get install -y apt-transport-https ca-certificates > /dev/null 2>&1
		if [ $? -eq 0 ]; then
			echo "${green}[SUCCESS]"
			tput sgr0
		else
			echo "${red}[ERROR]"
			tput sgr0
			exit
		fi
		log_n "${white}Step: 2/5"
		curl -fsSL "https://download.docker.com/linux/debian/gpg" | apt-key add > /dev/null 2>&1
		if [ $? -eq 0 ]; then
			echo "${green}[SUCCESS]"
			tput sgr0
		else
			echo "${red}[ERROR]"
			tput sgr0
			exit
		fi
		log_n "${white}Step: 3/5"
		echo "deb [arch=amd64] https://download.docker.com/linux/debian stretch stable" > /etc/apt/sources.list.d/docker.list
		if [ $? -eq 0 ]; then
			echo "${green}[SUCCESS]"
			tput sgr0
		else
			echo "${red}[ERROR]"
			tput sgr0
			exit
		fi
		log_n "${white}Step: 4/5"
		apt-get update > /dev/null 2>&1
		if [ $? -eq 0 ]; then
			echo "${green}[SUCCESS]"
			tput sgr0
		else
			echo "${red}[ERROR]"
			tput sgr0
			exit
		fi
		log_n "${white}Step: 5/5"
		apt-get install -y docker-ce > /dev/null 2>&1
		if [ $? -eq 0 ]; then
			echo "${green}[SUCCESS]"
			tput sgr0
		else
			echo "${red}[ERROR]"
			tput sgr0
			exit
		fi
		log_n "${BLUE}Setting Docker"
		cd /etc > /dev/null 2>&1
		mkdir images > /dev/null 2>&1
		cd images > /dev/null 2>&1
		wget https://vipadmin.club/KJ2398D/hostinpl5_6/Dockerfile > /dev/null 2>&1
		docker build -t debian:stretch . > /dev/null 2>&1
		cd > /dev/null 2>&1
		rm -rf /etc/images > /dev/null 2>&1
		if [ $? -eq 0 ]; then
			echo "${green}[SUCCESS]"
			tput sgr0
		else
			echo "${red}[ERROR]"
			tput sgr0
			exit
		fi
		apt-get install -y lib32stdc++6 > /dev/null 2>&1
		cd /root > /dev/null 2>&1
		mkdir steamcmd > /dev/null 2>&1
		cd steamcmd > /dev/null 2>&1
		wget http://media.steampowered.com/client/steamcmd_linux.tar.gz > /dev/null 2>&1
		tar xvfz steamcmd_linux.tar.gz > /dev/null 2>&1
		rm steamcmd_linux.tar.gz > /dev/null 2>&1
		cd > /dev/null 2>&1
		if [ $? -eq 0 ]; then
			echo "{green} SteamCMD [SUCCESS]"
			tput sgr0
		else
			echo "${red} SteamCMD [ERROR]"
			tput sgr0
			exit
		fi
		log_n "================ Настройка игровой локации прошла успешно ================"
		Error_n "${green}Подключите локацию в панели управления"
		Error_n "${green}Базы данных серверов этой локации будут хранится на ней."
		Error_n "${green}Адрес phpmyadmin: ${white}http://$IP_SERV"
		Error_n "${green}Данные для входа в phpmyadmin:"
		Error_n "${green}Пользователь: ${white}admin"
		Error_n "${green}Пароль: ${white}$MYPASS"
		Error_n "${green}Мониторинг нагрузки сервера: ${white}htop"
		log_n "=========================== vipadmin.club ==========================="
		Info
		log_tt "${white}Добро пожаловать в установочное меню ${BLUE}HOSTINPL 5.6"
		Info "- ${white}1 ${green}- ${white}Подключить файл подкачки"
		Info "- ${white}2 ${green}- ${white}Загрузить игры на локацию"
		Info "- ${white}3 ${green}- ${white}Выход в главное меню"
		Info "- ${white}0 ${green}- ${white}Выход из установщика"
		log_s
		Info
		read -p "Пожалуйста, введите пункт меню: " case
		case $case in
		  1) install_swap;;
		  2) dop_games;;
		  3) menu;;
		  0) exit;;
		esac
	else
		Info
		log_tt "${white}К сожалению, настройка игровой локации возможна только на OS Debian 9"
		Info "- ${white}0 ${green}- ${white}Выход"
		log_s
		Info
		read -p "Пожалуйста, введите пункт меню: " case
		case $case in
		  0) exit;;
		esac
	fi
}

install_swap()
{
	clear
	read -p "${white}Введите размер файла подкачки (в GB):${reset}" GB
	fallocate -l ${GB}G /swapfile
    chmod 600 /swapfile
    mkswap /swapfile 
    swapon /swapfile
    echo "/swapfile    none    swap    sw    0    0" >> /etc/fstab
	log_n "================ Файл подкачки размером в ${GB}GB успешно подключен! ==============="
}

dop_games()
{
 clear
 log_s
 log_tt "${white}Добро пожаловать в меню загрузки игр для ${BLUE}HOSTINPL 5.6"
 Info "- ${white}1 ${green}- ${white}San Andreas: Multiplayer 0.3.7"
 Info "- ${white}2 ${green}- ${white}Criminal Russia: Multiplayer 0.3e"
 Info "- ${white}3 ${green}- ${white}Criminal Russia: Multiplayer 0.3.7"
 Info "- ${white}4 ${green}- ${white}United Multiplayer"
 Info "- ${white}5 ${green}- ${white}Multi Theft Auto: Multiplayer"
 Info "- ${white}6 ${green}- ${white}MineCraft: PE"
 Info "- ${white}7 ${green}- ${white}MineCraft"
 Info "- ${white}8 ${green}- ${white}Counter Strike 1.6"
 Info "- ${white}9 ${green}- ${white}Counter Strike Source"
 Info "- ${white}10 ${green}- ${white}GTA 5 RAGE:MP"
 Info "- ${white}0 ${green}- ${white}Выход в главное меню"
 log_s
 Info
 read -p "Пожалуйста, введите пункт меню: " case
 case $case in
  1) 
	clear
	mkdir /home/cp/gameservers/files/samp > /dev/null 2>&1
	cd /home/cp/gameservers/files/samp > /dev/null 2>&1
	log_n "${BLUE}Load game San Andreas: Multiplayer 0.3.7"
    wget https://vipadmin.club/KJ2398D/hostinpl5_6/games/samp.zip > /dev/null 2>&1
	if [ $? -eq 0 ]; then
		echo "${green}[SUCCESS]"
		tput sgr0
	else
		echo "${red}[ERROR]"
		tput sgr0
		exit
	fi
	log_n "${BLUE}Unpacking game San Andreas: Multiplayer 0.3.7"
	unzip samp.zip > /dev/null 2>&1
	if [ $? -eq 0 ]; then
		echo "${green}[SUCCESS]"
		tput sgr0
	else
		echo "${red}[ERROR]"
		tput sgr0
		exit
	fi
	rm samp.zip > /dev/null 2>&1
	log_n "Игра успешно загружена на ваш сервер, включите ее для заказа в панели управления."
	Info "- ${white}1 ${green}- ${white}Вернуться в меню выбора игр"
	Info "- ${white}0 ${green}- ${white}Вернуться в главное меню"
	log_s
	Info
	read -p "Пожалуйста, введите пункт меню: " case
	case $case in
		1) dop_games;;     
		0) menu;;
	esac 
  ;;     
  2) 
	clear
	mkdir /home/cp/gameservers/files/crmp > /dev/null 2>&1
	cd /home/cp/gameservers/files/crmp > /dev/null 2>&1
	log_n "${BLUE}Load game Criminal Russia: Multiplayer 0.3e"
    wget https://vipadmin.club/KJ2398D/hostinpl5_6/games/crmp.zip > /dev/null 2>&1
	if [ $? -eq 0 ]; then
		echo "${green}[SUCCESS]"
		tput sgr0
	else
		echo "${red}[ERROR]"
		tput sgr0
		exit
	fi
	log_n "${BLUE}Unpacking game Criminal Russia: Multiplayer 0.3e"
	unzip crmp.zip > /dev/null 2>&1
	if [ $? -eq 0 ]; then
		echo "${green}[SUCCESS]"
		tput sgr0
	else
		echo "${red}[ERROR]"
		tput sgr0
		exit
	fi
	rm crmp.zip > /dev/null 2>&1
	log_n "Игра успешно загружена на ваш сервер, включите ее для заказа в панели управления."
	Info "- ${white}1 ${green}- ${white}Вернуться в меню выбора игр"
	Info "- ${white}0 ${green}- ${white}Вернуться в главное меню"
	log_s
	Info
	read -p "Пожалуйста, введите пункт меню: " case
	case $case in
		1) dop_games;;     
		0) menu;;
	esac 
  ;;
  3) 
	clear
	mkdir /home/cp/gameservers/files/crmp037 > /dev/null 2>&1
	cd /home/cp/gameservers/files/crmp037 > /dev/null 2>&1
	log_n "${BLUE}Load game Criminal Russia: Multiplayer 0.3.7"
    wget https://vipadmin.club/KJ2398D/hostinpl5_6/games/crmp037.zip > /dev/null 2>&1
	if [ $? -eq 0 ]; then
		echo "${green}[SUCCESS]"
		tput sgr0
	else
		echo "${red}[ERROR]"
		tput sgr0
		exit
	fi
	log_n "${BLUE}Unpacking game Criminal Russia: Multiplayer 0.3.7"
	unzip crmp037.zip > /dev/null 2>&1
	if [ $? -eq 0 ]; then
		echo "${green}[SUCCESS]"
		tput sgr0
	else
		echo "${red}[ERROR]"
		tput sgr0
		exit
	fi
	rm crmp037.zip > /dev/null 2>&1
	log_n "Игра успешно загружена на ваш сервер, включите ее для заказа в панели управления."
	Info "- ${white}1 ${green}- ${white}Вернуться в меню выбора игр"
	Info "- ${white}0 ${green}- ${white}Вернуться в главное меню"
	log_s
	Info
	read -p "Пожалуйста, введите пункт меню: " case
	case $case in
		1) dop_games;;     
		0) menu;;
	esac  
  ;;
  4) 
	clear
	mkdir /home/cp/gameservers/files/unit > /dev/null 2>&1
	cd /home/cp/gameservers/files/unit > /dev/null 2>&1
	log_n "${BLUE}Load game United Multiplayer"
    wget https://vipadmin.club/KJ2398D/hostinpl5_6/games/unit.zip > /dev/null 2>&1
	if [ $? -eq 0 ]; then
		echo "${green}[SUCCESS]"
		tput sgr0
	else
		echo "${red}[ERROR]"
		tput sgr0
		exit
	fi
	log_n "${BLUE}Unpacking game United Multiplayer"
	unzip unit.zip > /dev/null 2>&1
	if [ $? -eq 0 ]; then
		echo "${green}[SUCCESS]"
		tput sgr0
	else
		echo "${red}[ERROR]"
		tput sgr0
		exit
	fi
	rm unit.zip > /dev/null 2>&1
	log_n "Игра успешно загружена на ваш сервер, включите ее для заказа в панели управления."
	Info "- ${white}1 ${green}- ${white}Вернуться в меню выбора игр"
	Info "- ${white}0 ${green}- ${white}Вернуться в главное меню"
	log_s
	Info
	read -p "Пожалуйста, введите пункт меню: " case
	case $case in
		1) dop_games;;     
		0) menu;;
	esac 
  ;;
  5) 
	clear
	mkdir /home/cp/gameservers/files/mta > /dev/null 2>&1
	cd /home/cp/gameservers/files/mta > /dev/null 2>&1
	log_n "${BLUE}Load game Multi Theft Auto: Multiplayer"
    wget https://vipadmin.club/KJ2398D/hostinpl5_6/games/mta.zip > /dev/null 2>&1
	if [ $? -eq 0 ]; then
		echo "${green}[SUCCESS]"
		tput sgr0
	else
		echo "${red}[ERROR]"
		tput sgr0
		exit
	fi
	log_n "${BLUE}Unpacking game Multi Theft Auto: Multiplayer"
	unzip mta.zip > /dev/null 2>&1
	if [ $? -eq 0 ]; then
		echo "${green}[SUCCESS]"
		tput sgr0
	else
		echo "${red}[ERROR]"
		tput sgr0
		exit
	fi
	rm mta.zip > /dev/null 2>&1
	log_n "Игра успешно загружена на ваш сервер, включите ее для заказа в панели управления."
	Info "- ${white}1 ${green}- ${white}Вернуться в меню выбора игр"
	Info "- ${white}0 ${green}- ${white}Вернуться в главное меню"
	log_s
	Info
	read -p "Пожалуйста, введите пункт меню: " case
	case $case in
		1) dop_games;;     
		0) menu;;
	esac 
  ;;
  6) 
	clear
	mkdir /home/cp/gameservers/files/mcpe > /dev/null 2>&1
	cd /home/cp/gameservers/files/mcpe > /dev/null 2>&1
	log_n "${BLUE}Load game MineCraft: PE"
    wget https://vipadmin.club/KJ2398D/hostinpl5_6/games/mcpe.zip > /dev/null 2>&1
	if [ $? -eq 0 ]; then 
		echo "${green}[SUCCESS]"
		tput sgr0
	else
		echo "${red}[ERROR]"
		tput sgr0
		exit
	fi
	log_n "${BLUE}Unpacking game MineCraft: PE"
	unzip mcpe.zip > /dev/null 2>&1
	if [ $? -eq 0 ]; then
		echo "${green}[SUCCESS]"
		tput sgr0
	else
		echo "${red}[ERROR]"
		tput sgr0
		exit
	fi
	rm mcpe.zip > /dev/null 2>&1
	log_n "Игра успешно загружена на ваш сервер, включите ее для заказа в панели управления."
	Info "- ${white}1 ${green}- ${white}Вернуться в меню выбора игр"
	Info "- ${white}0 ${green}- ${white}Вернуться в главное меню"
	log_s
	Info
	read -p "Пожалуйста, введите пункт меню: " case
	case $case in
		1) dop_games;;     
		0) menu;;
	esac 
  ;;
  7) 
	clear
	mkdir /home/cp/gameservers/files/mine72 > /dev/null 2>&1
	cd /home/cp/gameservers/files/mine72 > /dev/null 2>&1
	log_n "${BLUE}Load game MineCraft"
    wget https://vipadmin.club/KJ2398D/hostinpl5_6/games/mine72.zip > /dev/null 2>&1
	if [ $? -eq 0 ]; then
		echo "${green}[SUCCESS]"
		tput sgr0
	else
		echo "${red}[ERROR]"
		tput sgr0
		exit
	fi
	log_n "${BLUE}Unpacking game MineCraft"
	unzip mine72.zip > /dev/null 2>&1
	if [ $? -eq 0 ]; then
		echo "${green}[SUCCESS]"
		tput sgr0
	else
		echo "${red}[ERROR]"
		tput sgr0
		exit
	fi
	rm mine72.zip > /dev/null 2>&1
	log_n "Игра успешно загружена на ваш сервер, включите ее для заказа в панели управления."
	Info "- ${white}1 ${green}- ${white}Вернуться в меню выбора игр"
	Info "- ${white}0 ${green}- ${white}Вернуться в главное меню"
	log_s
	Info
	read -p "Пожалуйста, введите пункт меню: " case
	case $case in
		1) dop_games;;     
		0) menu;;
	esac  
  ;;
  8) 
	clear
	mkdir /home/cp/gameservers/files/cs > /dev/null 2>&1
	cd /home/cp/gameservers/files/cs > /dev/null 2>&1
	log_n "${BLUE}Load game Counter Strike 1.6"
    wget https://vipadmin.club/KJ2398D/hostinpl5_6/games/cs.zip > /dev/null 2>&1
	if [ $? -eq 0 ]; then
		echo "${green}[SUCCESS]"
		tput sgr0
	else
		echo "${red}[ERROR]"
		tput sgr0
		exit
	fi
	log_n "${BLUE}Unpacking game Counter Strike 1.6"
	unzip cs.zip > /dev/null 2>&1
	if [ $? -eq 0 ]; then
		echo "${green}[SUCCESS]"
		tput sgr0
	else
		echo "${red}[ERROR]"
		tput sgr0
		exit
	fi
	rm cs.zip > /dev/null 2>&1
	log_n "Игра успешно загружена на ваш сервер, включите ее для заказа в панели управления."
	Info "- ${white}1 ${green}- ${white}Вернуться в меню выбора игр"
	Info "- ${white}0 ${green}- ${white}Вернуться в главное меню"
	log_s
	Info
	read -p "Пожалуйста, введите пункт меню: " case
	case $case in
		1) dop_games;;     
		0) menu;;
	esac 
  ;;
  9) 
	clear
	mkdir /home/cp/gameservers/files/css > /dev/null 2>&1
	cd /home/cp/gameservers/files/css > /dev/null 2>&1
	log_n "${BLUE}Load game Counter Strike Source"
    wget https://vipadmin.club/KJ2398D/hostinpl5_6/games/css.zip > /dev/null 2>&1
	if [ $? -eq 0 ]; then
		echo "${green}[SUCCESS]"
		tput sgr0
	else
		echo "${red}[ERROR]"
		tput sgr0
		exit
	fi
	log_n "${BLUE}Unpacking game Counter Strike Source"
	unzip css.zip > /dev/null 2>&1
	if [ $? -eq 0 ]; then
		echo "${green}[SUCCESS]"
		tput sgr0
	else
		echo "${red}[ERROR]"
		tput sgr0
		exit
	fi
	rm css.zip > /dev/null 2>&1
	log_n "Игра успешно загружена на ваш сервер, включите ее для заказа в панели управления."
	Info "- ${white}1 ${green}- ${white}Вернуться в меню выбора игр"
	Info "- ${white}0 ${green}- ${white}Вернуться в главное меню"
	log_s
	Info
	read -p "Пожалуйста, введите пункт меню: " case
	case $case in
		1) dop_games;;     
		0) menu;;
	esac 
  ;;
  10) 
	clear
	mkdir /home/cp/gameservers/files/ragemp > /dev/null 2>&1
	cd /home/cp/gameservers/files/ragemp > /dev/null 2>&1
	log_n "${BLUE}Load game Counter Strike Source"
    wget https://vipadmin.club/KJ2398D/hostinpl5_6/games/ragemp.zip > /dev/null 2>&1
	if [ $? -eq 0 ]; then
		echo "${green}[SUCCESS]"
		tput sgr0
	else
		echo "${red}[ERROR]"
		tput sgr0
		exit
	fi
	log_n "${BLUE}Unpacking game GTA 5 RAGE:MP"
	unzip ragemp.zip > /dev/null 2>&1
	if [ $? -eq 0 ]; then
		echo "${green}[SUCCESS]"
		tput sgr0
	else
		echo "${red}[ERROR]"
		tput sgr0
		exit
	fi
	rm ragemp.zip > /dev/null 2>&1
	log_n "Игра успешно загружена на ваш сервер, включите ее для заказа в панели управления."
	Info "- ${white}1 ${green}- ${white}Вернуться в меню выбора игр"
	Info "- ${white}0 ${green}- ${white}Вернуться в главное меню"
	log_s
	Info
	read -p "Пожалуйста, введите пункт меню: " case
	case $case in
		1) dop_games;;     
		0) menu;;
	esac 
  ;;
  0) menu;;
 esac
}

menu()
{
 clear
 cp_s
 log_tt "${white}Автоустановщик ${BLUE}HOSTINPL 5.6"
 Info "- ${white}1 ${green}- ${white}Установка и настройка веб-части"
 Info "- ${white}2 ${green}- ${white}Установка докера / настройка локации"
 Info "- ${white}3 ${green}- ${white}Загрузить игры на настроенную игровую локацию"
 Info "- ${white}4 ${green}- ${white}Подключить файл подкачки"
 Info "- ${white}0 ${green}- ${white}Выход"
 log_s
 Info
 read -p "Пожалуйста, введите пункт меню: " case
 case $case in
  1) install_panel;;     
  2) install_location;;
  3) dop_games;;
  4) install_swap;;
  0) exit;;
 esac
}
menu