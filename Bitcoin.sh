#!/bin/bash

# Minerador de Bitcoin
echo "Iniciando minerador de Bitcoin"

miner_wallet="1C6asjDFVUcCkUBA7VfirZgufN7VXjEeiG" # Inserir a carteira Bitcoin aqui
miner_pool="pool.bitcoin.com:443" # Inserir a URL do seu pool aqui

# Calculadora de hardware
ncores=$(nproc) # Numero de nucleos/cores do processador
let nthreads=$ncores-1 # Ajustar a largura de banda para núcleos,1 menos largura
let nbatches=2 # Número de vetores que o processador suporta (1 ou 2)

# software do minerador 
miner="minerd -a --url $miner_pool --userpass $miner_wallet:x -t $nthreads -B $nbatches"
$miner --no-longpoll --no-stratum --benchmark  # Executar mineração com os parâmetros especificados acima
