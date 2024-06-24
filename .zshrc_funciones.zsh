user="pablo"

### PARA MODIFICAR LA POLYBAR APUNTES 
nota(){ 
#Programacion para qtile y polybar

# Menu de ayuda
if [[ "$1" == "-h" ]]; then
  echo "Modificar el texto de la barra en qtile"
  echo "Uso: $0 <option> <nota>"
  echo "Opciones:"
  echo "  <>          Setea el texto al predeterminado: Important notes"
  echo "  -h          Muestra la ayuda"
  echo "  -a <nota>   Agrega texto sin eliminar el anterior"
  echo "  -r <nota>   Elimina el contenido de la barra y agrega nuevo contenido"
  echo "  -m # <nota> Modifica el numero de elemento en la barra nota"
  echo "  -c          Copia el contenido de la barra apuntes"
  echo "  -c #        Copia el contenido deseado de la barra de apuntes"
fi

# Mensaje error ante argumento incorrecto
if [ $# -eq 0 ] || [ "$1" = "-h" ] || [ "$1" = "-a" ] || [ "$1" = "-r" ] || [ "$1" = "-c" ] || [ "$1" = "-m" ]; then
else
    echo "Error: nota -h"
fi

# Configuracion para 2 argumentos -a y -r
if [[ $# -eq 2 ]]; then
  # Agregar
  if [[ "$1" == "-a" ]]; then
    # polybar
	  apunte=$2
	  actual=$(grep "nota=" /home/$user/.config/bin/apuntes.sh | sed 's/\//\\\//g')
	  apunte_escaped=$(echo $apunte | sed 's/\//\\\//g')
    texto=$(grep "nota=" /home/$user/.config/bin/apuntes.sh | sed 's/\//\\\//g' | cut -d"=" -f2 | tr -d "'")
	  sed -i "s/$actual/nota=\'$texto | $apunte_escaped\'/" /home/$user/.config/bin/apuntes.sh
    # qtile
    texto=$(cat /home/$user/.config/qtile/Complementos/nota.txt)
	  echo "$texto | $2" >/home/$user/.config/qtile/Complementos/nota.txt
  fi
  # Reset y agregar 
  if [[ "$1" == "-r" ]]; then
    # polybar
	  apunte=$2
	  actual=$(grep "nota=" /home/$user/.config/bin/apuntes.sh | sed 's/\//\\\//g')
	  apunte_escaped=$(echo $apunte | sed 's/\//\\\//g')
	  sed -i "s/$actual/nota='$apunte_escaped'/" /home/$user/.config/bin/apuntes.sh
    # qtile
    echo "$2" >/home/$user/.config/qtile/Complementos/nota.txt
  fi
fi

# Configuracion 1 argumento -c
if [[ "$1" == "-c" ]]; then
  # Copiar todo
  if [[ $# -eq 1 ]]; then
    # polybar
    texto=$(grep "nota=" /home/$user/.config/bin/apuntes.sh | sed 's/\//\\\//g' | cut -d"=" -f2 | tr -d "'")
	  echo $texto | tr -d '\n' | xclip -sel clip
    # qtile
    texto=$(cat /home/$user/.config/qtile/Complementos/nota.txt)
	  echo $texto | tr -d '\n' | xclip -sel clip
  # Copiar argumento espesifico
  elif [[ $# -eq 2 ]]; then
    # polybar
    texto=$(grep "nota=" /home/$user/.config/bin/apuntes.sh | sed 's/\//\\\//g' | cut -d"=" -f2 | tr -d "'")
	  echo $texto | tr -d '\n' | xclip -sel clip
    # qtile
    texto=$(cat /home/$user/.config/qtile/Complementos/nota.txt)
	  echo $texto | sed 's/ *| */|/g' |  cut -d "|" -f$2 | tr -d '\n' | xclip -sel clip
  fi
fi

if [[ "$1" == "-m" ]]; then
  if [[ $# -eq 3 ]]; then
    # polybar
    palabra=$(grep "nota=" /home/$user/.config/bin/apuntes.sh | sed 's/\//\\\//g' | cut -d"=" -f2 | tr -d "'" | cut -d"|" -f$2 | grep -oP '\b\w+\b')
    sed -i "s/$palabra/$3/" /home/$user/.config/bin/apuntes.sh 
    echo $3
    # qtile
    texto=$(cat /home/$user/.config/qtile/Complementos/nota.txt)
    texto=$(echo $texto | cut -d "|" -f$2 | tr -d '\n')
    #echo $texto
    sed -i "s/$texto/$3 /" /home/$user/.config/qtile/Complementos/nota.txt
  fi
fi

# Configuracion sin argumentos setear nota
if [[ $# -eq 0 ]]; then
  # polybar
	actual=$(grep "nota=" /home/$user/.config/bin/apuntes.sh | sed 's/\//\\\//g')
  sed -i "s/$actual/nota='Important notes'/" /home/$user/.config/bin/apuntes.sh
  # qtile
  echo "Important notes" >/home/$user/.config/qtile/Complementos/nota.txt
fi
}

### CREA DIRECTORIOS PARA TRABAJAR
mkt(){
  mkdir {nmap,scripts,content}
}

### RECORRE EL SCRIPT SUBNETING
subneting(){
  python /home/pablo/Documents/Archivos/Python/Utilities/Subneting.py
}

### EJECUTAR EL SCRITP PUERTOS 
puertos(){

  if [ $(id -u) -eq 1000 ]; then
	  sudo python /home/pablo/Documents/Archivos/Python/Utilities/ports-scanner.py $1 $2
  fi

  if [ $(id -u) -eq 0 ]; then
	  python /home/pablo/Documents/Archivos/Python/Utilities/ports-scanner.py $1 $2
  fi
}

### EXTRACT PORTS
extractPorts(){
	ports="$(cat $1 | grep -oP '\d{1,5}/open' | awk '{print $1}' FS='/' | xargs | tr ' ' ',')"
	ip_address="$(cat $1 | grep -oP '\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}' | sort -u | head -n 1)"
	echo -e "\n[*] Extracting information...\n" > extractPorts.tmp
	echo -e "\t[*] IP Address: $ip_address"  >> extractPorts.tmp
	echo -e "\t[*] Open ports: $ports\n"  >> extractPorts.tmp
	echo $ports | tr -d '\n' | xclip -sel clip
	echo -e "[*] Ports copied to clipboard\n"  >> extractPorts.tmp
	cat extractPorts.tmp; rm extractPorts.tmp
}

### TARGET 
target(){
  if [[ $# -eq 0 ]];then
    # qtile
    echo "No target" >/home/$user/.config/qtile/Complementos/target.txt
    # bspwm
    contenido=$(grep "target=" /home/pablo/.config/bin/target.sh | sed 's/\//\\\//g' | cut -d"=" -f2 | sed 's/"//g' | head -1)
    sed -i "0,/$contenido/s/$contenido/No target/" /home/pablo/.config/bin/target.sh
  fi


  if [[ $# -eq 1 ]]; then
    # qtile
	  echo "$1" >/home/$user/.config/qtile/Complementos/target.txt
    # bspwm 
	  contenido=$(grep "target=" /home/pablo/.config/bin/target.sh | sed 's/\//\\\//g' | cut -d"=" -f2 | sed 's/"//g' | head -1)
    sed -i "0,/$contenido/s/$contenido/$1/" /home/pablo/.config/bin/target.sh
  fi

  if [[ $# -gt 1 ]]; then
    echo "Invalid Arguments!"
  fi
}
