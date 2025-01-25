#!/bin/bash
#
# Hudson Bomfim 2025.0120

# altere a linha abaixo com os seus numeros da teimosinha (numeros que vc sempre jopga)
jogo1=("01" "02" "03" "04" "05" "06" "07" "08" "09" "10" "11" "12" "13" "14" "15")
#
function ajuda(){
		echo "v 2025.0120"
		echo "./lotofacil.sh  >> /var/log/lotofacil.log [download do ultimo resultado e conta pontos]"
		echo "./lotofacil.sh  -n N >> /var/log/lotofacil.log [download do resultado do concurso N e conta pontos]"
}
#
#
function premio(){
	local acertos=$1
	#
	if [ "$acertos" -eq 11 ]
	then
		PREMIO="6,00"
    	# return 6
	elif [ "$acertos" -eq 12 ]
	then
		PREMIO="12,00"
    	# return 12
	elif [ "$acertos" -eq 13 ]
	then
		PREMIO="30,00"
    	# return 30
	elif [ "$acertos" -eq 14 ]
	then
		PREMIO="Premio de 14 pts"
		# return 100
    	# echo "PREMIO: $premio14"
	elif [ "$acertos" -eq 15 ]
	then
		PREMIO="15 POMTOS - PREMIO MAXIMO"
		# return 200
    	# echo "PREMIO: $premio15"
	else
		PREMIO="-"
		echo "" > /dev/null
		# return 0
	fi
}
#
function ultimoConcurso(){
	# v2 somente com o curl e usando a API da caixa
	curl -k -s  https://servicebus2.caixa.gov.br/portaldeloterias/api/home/ultimos-resultados -o /tmp/html.txt
	dataApuracao=$(grep -A 4 'lotofacil' /tmp/html.txt | grep 'dataApuracao' | grep -o '[0-3][0-9]/[0-9][0-9]/[0-9]\{4\}');
	concurso=$(grep -A 28 'lotofacil' /tmp/html.txt | grep 'numeroDoConcurso' | grep -o '[0-9]\{4\}');
	dezenas=$(grep -A 28 'lotofacil' /tmp/html.txt | grep -A 15 'dezenas' | grep -o '[0-2][0-9]')
	grep -A 28 'lotofacil' /tmp/html.txt | grep -A 15 'dezenas' | grep -o '[0-2][0-9]' > /tmp/lotofacil.txt
}
#
function numeroConcurso(){
	curl -k -s  https://servicebus2.caixa.gov.br/portaldeloterias/api/lotofacil/"$1" -o /tmp/html.txt
	dataApuracao=$(grep 'dataApuracao' /tmp/html.txt | grep -o '[0-3][0-9]/[0-9][0-9]/[0-9]\{4\}');
	concurso=$1
	# dezenas=$(grep -A 15 'dezenas' /tmp/html.txt | grep -o '[0-2][0-9]')
	grep -A 15 'dezenas' /tmp/html.txt | grep -o '[0-2][0-9]' > /tmp/lotofacil.txt
}
#
function logPontos(){

	# OUTPUT
	echo -e "Concurso: $concurso"
	echo -e "Data    : $dataApuracao"
	echo "Aposta :" "${jogo1[@]}"

	arquivoEntrada="/tmp/lotofacil.txt"

	# JOGO_1
	acertos=0
	while read linha
	do
	 for x in {0..14}
	 do
	 	if [ "$linha" = "${jogo1[x]}" ]
	   	then
	 	let acertos++
	 	sed -i "s/$linha/[$linha]/" /tmp/lotofacil.txt
	 	fi
	 done
	done < $arquivoEntrada
	premio $acertos
		valor="$?"
		dezenas=$(cat /tmp/lotofacil.txt | sort | tr '\n' ' ')
		echo "Dezens : $dezenas"
		echo ""
		echo -e "QTD acertos: $acertos\tvalor: $PREMIO"
		echo "-------------------------------------------------"
}
# CASE
case $1 in
	-h) 	ajuda 										;;
	"") 	ultimoConcurso; logPontos 					;;
	-n)		numeroConcurso $2; logPontos 				;;
esac
