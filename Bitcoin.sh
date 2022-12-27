#!/bin/bash

# Minerador de Bitcoin
echo "Iniciando minerador de Bitcoin"

# Inicializar variáveis com valores padrão
miner_wallet=""
miner_pool=""
nthreads=1
nbatches=1

# Processar opções de linha de comando
while getopts "w:p:t:b:" opt; do
  case $opt in
    w) miner_wallet="$OPTARG"
    ;;
    p) miner_pool="$OPTARG"
    ;;
    t) nthreads="$OPTARG"
    ;;
    b) nbatches="$OPTARG"
    ;;
    \?) echo "Opção inválida: -$OPTARG" >&2
    exit 1
    ;;
  esac
done

# Verificar se as opções obrigatórias foram fornecidas
if [[ -z "$miner_wallet" ]] || [[ -z "$miner_pool" ]]; then
  echo "Erro: carteira e pool de mineração são obrigatórios"
  exit 1
fi

# software do minerador 
miner="minerd -a --url $miner_pool --userpass $miner_wallet:x -t $nthreads -B $nbatches"
$miner --no-longpoll --no-stratum --benchmark  # Executar mineração com os parâmetros especificados acima
