#
# IAC 2023/2024 k-means
# 
# Grupo:
# Campus: Alameda
#
# Autores:
# 110355, Madalena Mota
# 103900, Martim Nobrega
# 109247, Ema Ferrao
#
# Tecnico/ULisboa


# ALGUMA INFORMACAO ADICIONAL PARA CADA GRUPO:
# - A "LED matrix" deve ter um tamanho de 32 x 32
# - O input e' definido na seccao .data. 
# - Abaixo propomos alguns inputs possiveis. Para usar um dos inputs propostos, basta descomentar 
#   esse e comentar os restantes.
# - Encorajamos cada grupo a inventar e experimentar outros inputs.
# - Os vetores points e centroids estao na forma x0, y0, x1, y1, ...


# Variaveis em memoria
.data

.equ         LED_MATRIX_HEIGHT 32
.equ         LED_MATRIX_WIDTH 32

#Input A - linha inclinada
#n_points:    .word 9
#points:      .word 0,0, 1,1, 2,2, 3,3, 4,4, 5,5, 6,6, 7,7 8,8

#Input B - Cruz
#n_points:    .word 5
#points:     .word 4,2, 5,1, 5,2, 5,3 6,2

#Input C
#n_points:    .word 23
#points: .word 0,0, 0,1, 0,2, 1,0, 1,1, 1,2, 1,3, 2,0, 2,1, 5,3, 6,2, 6,3, 6,4, 7,2, 7,3, 6,8, 6,9, 7,8, 8,7, 8,8, 8,9, 9,7, 9,8

#Input D
n_points:    .word 30
points:      .word 16, 1, 17, 2, 18, 6, 20, 3, 21, 1, 17, 4, 21, 7, 16, 4, 21, 6, 19, 6, 4, 24, 6, 24, 8, 23, 6, 26, 6, 26, 6, 23, 8, 25, 7, 26, 7, 20, 4, 21, 4, 10, 2, 10, 3, 11, 2, 12, 4, 13, 4, 9, 4, 9, 3, 8, 0, 10, 4, 10



# Valores de centroids e k a usar na 1a parte do projeto:
#centroids:   .word 0,0
#k:           .word 1

# Valores de centroids, k e L a usar na 2a parte do prejeto:
#centroids:   .word 0,0, 10,0, 0,10
centroids:    .word 2, 8, 14, 0, 0, 24
k:           .word 3
L:           .word 10

# Abaixo devem ser declarados o vetor clusters (2a parte) e outras estruturas de dados
# que o grupo considere necessarias para a solucao:
clusters:     .zero 120   
media_points: .zero 20




#Definicoes de cores a usar no projeto 

colors:      .word 0xff0000, 0x00ff00, 0x0000ff  # Cores dos pontos do cluster 0, 1, 2, etc.

.equ         black      0
.equ         white      0xffffff
.equ         green      0x00ff00



# Strings a imprimir no fim de cada passo
limpa_matriz:     .string "Limpa matriz\n"
print_cluster:    .string "Print cluster\n"
calcula_centroid: .string "Calcula centroide\n"
separador:        .string ", "
nova_linha:       .string "\n"


# Codigo
 
.text
    # Chama funcao principal da 1a parte do projeto
    # jal mainSingleCluster

    # Descomentar na 2a parte do projeto:
    # jal mainKMeans
    # jal initializeCentroids
    jal cleanScreen
    jal calculateClusters
    jal printClusters
    jal printCentroids
    
    #Termina o programa (chamando chamada sistema)
    li a7, 10
    ecall


### printPoint
# Pinta o ponto (x,y) na LED matrix com a cor passada por argumento
# Nota: a implementacao desta funcao ja' e' fornecida pelos docentes
# E' uma funcao auxiliar que deve ser chamada pelas funcoes seguintes que pintam a LED matrix.
# Argumentos:
# a0: x
# a1: y
# a2: cor

printPoint:
    li a3, LED_MATRIX_HEIGHT
    sub a1, a3, a1
    addi a1, a1, -1
    li a3, LED_MATRIX_WIDTH
    mul a3, a3, a1
    add a3, a3, a0
    slli a3, a3, 2
    li a0, LED_MATRIX_0_BASE
    add a3, a3, a0   # addr
    sw a2, 0(a3)
    jr ra
    

### cleanScreen
# Limpa todos os pontos do ecra
# Argumentos: nenhum
# Retorno: nenhum

cleanScreen:
    li t0, 0 # coordenada x
    li t2, LED_MATRIX_WIDTH
    li t3, LED_MATRIX_HEIGHT
    addi sp, sp, -4
    sw ra, 0(sp)
    
itera_x:
    li t1 0 # coordenada y
    
itera_y:
    mv a0, t0
    mv a1, t1
    li a2, white # cor de fundo
    jal printPoint 
    addi t1, t1, 1
    blt t1, t3, itera_y
    
    addi t0, t0, 1
    blt t0, t2, itera_x
    
    lw ra, 0(sp)
    addi sp, sp, 4
    
    la a0, limpa_matriz
    li a7, 4
    ecall
    jr ra  

    
### printClusters
# Pinta os agrupamentos na LED matrix com a cor correspondente.
# Argumentos: nenhum
# Retorno: nenhum

printClusters:
    la t1, colors
    # li t2, LED_MATRIX_WIDTH
    # li t3, LED_MATRIX_HEIGHT
    la t2, points
    la t3, clusters
    lw t4, n_points
    addi sp, sp, -4
    sw ra, 0(sp)

itera:
    lw a0, 0(t2) # x
    lw a1, 4(t2) # y
    addi t2, t2, 8
    
    lw t0, 0(t3) # indice cluster
    slli t0, t0, 2
    add t0, t0, t1 # endereco da cor
    lw a2, 0(t0)
    addi t3, t3, 4
    
    jal printPoint 
    addi t4, t4, -1
    bgt t4, x0, itera
    
    lw ra, 0(sp)
    addi sp, sp, 4
    
    # print
    la a0, print_cluster
    li a7, 4
    ecall
    jr ra


### printCentroids
# Pinta os centroides na LED matrix
# Nota: deve ser usada a cor preta (black) para todos os centroides
# Argumentos: nenhum
# Retorno: nenhum

printCentroids:
    lw t0, k # contar numero de iteracoes
    la t1, centroids # endereco do vetor de centroides
    li a2, black
    #la t2, colors # Endereco do vetor de cores
    addi sp, sp, -4
    sw ra, 0(sp)
    
executaPrintCentroids:
    addi t0, t0, -1 # Decrementar o iterador
    lw a0, 0(t1) # x
    lw a1, 4(t1) # y
    #slli t3, t0, 2
    #add t3, t2, t3 # Escolher o indice do vetor de cores
    #lw a2, 0(t3) # Escolher a cor
    addi t1, t1, 8
    jal printPoint
    bgt t0, x0, executaPrintCentroids
    
    lw ra, 0(sp)
    addi sp, sp, 4
    jr ra

### calculateCentroids
# Calcula os k centroides, a partir da distribuicao atual de pontos associados a cada agrupamento (cluster)
# Argumentos: nenhum
# Retorno: nenhum

calculateCentroids:
    addi sp, sp, -8
    sw s1, 0(sp)
    sw s2, 4(sp)

    li t0, 0 # contador de iteracoes
    lw t1, n_points 
    la t2, points # endereco do vetor de pontos
    la s1, clusters # endereco do vetor de clusters
    la s2, media_points

somaCoordenadas:
    lw t3, 0(t2) # coordenada x
    lw t4, 4(t2) # coordenada y
    lw t5, 0(s1) # ver a que cluster o ponto pertence
    slli t5, t5, 2
    add t5, t5, s2 # endereco do media_points no cluster certo 
    lw t6, 0(t5) # load da soma dos x do cluster
    add t6, t6, t3
    sw t6, 0(t5) # atualizar soma dos x do cluster
    lw t6, 4(t5) # load da soma dos y do cluster
    add t6, t6, t4
    sw t6, 4(t5) # atualizar soma dos y do cluster
    lw t6, 8(t5) # load do numero de pontos do cluster
    addi t6, t6, 1
    sw t6, 8(t5)
    addi t2, t2, 8 # avancar para proximo ponto
    addi s1, s1, 4
    addi t0, t0, 1
    ble t0, t1, somaCoordenadas
    li t0, 0
    lw t4, k
    la s1, centroids

calculaMedia:
    lw t1, 0(s2) # Soma das coordenadas x
    lw t2, 4(s2) # Soma das coordenadas y
    lw t3, 8(s2) # Numero de pontos
    div t1, t1, t3
    div t2, t2, t3
    sw t1, 0(s1)
    sw t2, 4(s1)
    addi s1, s1, 8
    addi s2, s2, 12
    addi t0, t0, 1
    blt t0, t4, calculaMedia 
    
    lw s2, 4(sp)
    lw s1, 0(sp)
    addi sp, sp, 8
    jr ra 
    

### mainSingleCluster
# Funcao principal da 1a parte do projeto.
# Argumentos: nenhum
# Retorno: nenhum

mainSingleCluster:

    jal cleanScreen

    jal printClusters

    jal calculateCentroids

    jal printCentroids

    #6. Termina
    jr ra



### manhattanDistance
# Calcula a distancia de Manhattan entre (x0,y0) e (x1,y1)
# Argumentos:
# a0, a1: x0, y0
# a2, a3: x1, y1
# Retorno:
# a0: distance

manhattanDistance:
    sub t0, a0, a2 #x0-x1
    sub t1, a1, a3 #y0-y1
    li t2, -1
    
modulos:
    blt t0, x0, modulo_x
    blt t1, x0, modulo_y
    add a0, t0, t1
    jr ra
    
modulo_x:
    mul t0, t0, t2
    j modulos
    
modulo_y:
    mul t1, t1, t2
    j modulos


### nearestCluster
# Determina o centroide mais perto de um dado ponto (x,y).
# Argumentos:
# a0, a1: (x, y) point
# Retorno:
# a0: cluster index

nearestCluster:
    addi sp, sp, -24
    sw ra, 0(sp)
    sw s0, 4(sp)
    sw s1, 8(sp)
    sw s2, 12(sp)
    sw s3, 16(sp)
    sw s4, 20(sp)
    
    la s0, centroids # Endereco do vetor de centroides
    lw s1, k # Contador de iteracoes
    li s4, 0
    
    # Inicializar a width + height
    li s2, LED_MATRIX_WIDTH
    li s3, LED_MATRIX_HEIGHT
    add s2, s2, s3  # Guarda a maior distancia possivel
    
    # Inicializar o indice da menor distancia
    li s3, 0
    mv t6, a0 # guardar x
    
calculaManhattanDistance:
    mv a0, t6
    lw a2, 0(s0) # Colocar os valores nos resgistos necessarios
    lw a3, 4(s0) # para calcular a manhattan distance
    addi s0, s0, 8 # Passa para o proximo centroide
    jal manhattanDistance # Calcular manhattan distance
    
    ### Calcular menor distancia ###
    blt a0, s2, updateMenorDistancia
        
terminaNearestCluster:
    addi s4, s4, 1
    ble s4, s1, calculaManhattanDistance
    mv a0, s3
    lw ra, 0(sp)
    lw s0, 4(sp)
    lw s1, 8(sp)
    lw s2, 12(sp)
    lw s3, 16(sp)
    lw s4, 20(sp)
    addi sp, sp, 24
    jr ra
    
updateMenorDistancia:
    # Guardar menor distancia
    mv s2, a0
    # Guardar indice do centroide mais proximo
    mv s3, s4
    j terminaNearestCluster
    
### initializeCentroids
# Argumentos: nenhum
# Retorno: nenhum
 
initializeCentroids:
    lw t0, k
    slli t0, t0, 1
    la t1, centroids
    
initializeCentroids_loop:
    li a7, 30
    ecall
    li t2, 32
    remu a0, a0, t2
    
    sw a0, 0(t1)
    addi t1, t1, 4
    addi t0, t0, -1
    bgt t0, x0, initializeCentroids_loop
    jr ra
    

### calculateClusters
# Argumentos: nenhum
# Retorno: nenhum

calculateClusters:
    addi sp, sp, -16
    sw ra, 0(sp)
    sw s0, 4(sp)
    sw s1, 8(sp)
    sw s2, 12(sp)
    
    la s0, points
    la s1, clusters
    lw s2, n_points
    
calculateClusters_loop:
    lw a0, 0(s0) # x
    lw a1, 4(s0) # y
    addi s0, s0, 8
    jal nearestCluster
    sw a0, 0(s1)
    addi s1, s1, 4
    addi s2, s2, -1
    bgt s2, x0, calculateClusters_loop
    
    lw ra, 0(sp)
    lw s0, 4(sp)
    lw s1, 8(sp)
    lw s2, 12(sp)
    addi sp, sp, 16
    jr ra


### mainKMeans
# Executa o algoritmo *k-means*.
# Argumentos: nenhum
# Retorno: nenhum

mainKMeans:
    li s0, 1 # s0 eh 1 se houver alteracoes nos clusters
    li s1, 0 # iterador para comparar com L
    li s2, 0 # iterador do numero de pontos
    la s3, points
    la s4, clusters
    addi sp, sp, -4
    sw ra, 0(sp)
    #jal initializeCentroids
    
mainKMeansIteration:
    beq s0, x0, terminaMainKMeans # Se nao fizemos alteracoes, terminar
    li s0, 0
    jal cleanScreen
    jal calculateClusters
    jal calculateCentroids # Calcular novo vetor de centroides
    jal printCentroids
    jal printClusters
    addi s1, s1, 1
    lw t0, L
    blt s1, t0, mainKMeansIteration
    
terminaMainKMeans:
    lw ra, 0(sp)
    addi sp, sp, 4
    jr ra
    
    # 1. Escolher k pontos random para ser centroides (feito)
    # 2. Para cada ponto, ver qual centroide esta mais perto e agrupar o ponto nesse cluster
    # 3. Calcular novos centroides de acordo com os clusters obtidos
    # 4. Repetir o algoritmo ate nenhum ponto mudar de cluster
    