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
n_points:    .word 23
points: .word 0,0, 0,1, 0,2, 1,0, 1,1, 1,2, 1,3, 2,0, 2,1, 5,3, 6,2, 6,3, 6,4, 7,2, 7,3, 6,8, 6,9, 7,8, 8,7, 8,8, 8,9, 9,7, 9,8

#Input D
#n_points:    .word 30
#points:      .word 16, 1, 17, 2, 18, 6, 20, 3, 21, 1, 17, 4, 21, 7, 16, 4, 21, 6, 19, 6, 4, 24, 6, 24, 8, 23, 6, 26, 6, 26, 6, 23, 8, 25, 7, 26, 7, 20, 4, 21, 4, 10, 2, 10, 3, 11, 2, 12, 4, 13, 4, 9, 4, 9, 3, 8, 0, 10, 4, 10



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
media_points: .zero 120




#Definicoes de cores a usar no projeto 

colors:      .word 0xff0000, 0x00ff00, 0x0000ff  # Cores dos pontos do cluster 0, 1, 2, etc.

.equ         black      0
.equ         white      0xffffff
.equ         green      0x00ff00



# Strings a imprimir no fim de cada passo
limpa_matriz:         .string "Limpa matriz\n"
print_cluster:        .string "Print cluster\n"
coordenadas_centroid: .string "Coordenadas centroide "
numero_iteracoes:     .string "Numero de iteracoes: "
centroides_iniciais:  .string "Centroides iniciais"
nova_inicializacao:   .string "Nova inicializacao do cluster "
separador:            .string ", "
nova_linha:           .string "\n"


# Codigo
 
.text
    # Chama funcao principal da 1a parte do projeto
    # jal mainSingleCluster

    # Descomentar na 2a parte do projeto:
    jal mainKMeans
    #jal initializeCentroids
    #jal cleanScreen
    #jal calculateClusters
    #jal calculateCentroids
    #jal printClusters
    #jal printCentroids
    
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
    li a2, white # cor de fundo
    
    addi sp, sp, -4
    sw ra, 0(sp)
    
itera_x:
    li t1 0 # coordenada y
    
itera_y:
    mv a0, t0
    mv a1, t1
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
    la t2, points
    la t3, clusters
    lw t4, n_points
    addi sp, sp, -4
    sw ra, 0(sp)

printClusters_loop:
    lw a0, 0(t2) # x
    lw a1, 4(t2) # y
    addi t2, t2, 8
    
    lw t0, 0(t3) # indice cluster do ponto
    slli t0, t0, 2
    add t0, t0, t1 # endereco da cor
    lw a2, 0(t0)
    addi t3, t3, 4
    
    jal printPoint 
    addi t4, t4, -1
    bgt t4, x0, printClusters_loop
    
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
    addi sp, sp, -4
    sw ra, 0(sp)
    
executaPrintCentroids:
    addi t0, t0, -1 # Decrementar o iterador
    lw a0, 0(t1) # x
    lw a1, 4(t1) # y
    addi t1, t1, 8
    jal printPoint
    bgt t0, x0, executaPrintCentroids
    
    lw ra, 0(sp)
    addi sp, sp, 4
    jr ra

### calculateCentroids
# Calcula os k centroides, a partir da distribuicao atual de pontos associados a cada agrupamento (cluster)
# Argumentos: nenhum
# Retorno: 
# a0: 1 se centroides forem alterados, 0 caso contrario

calculateCentroids:
    addi sp, sp, -20
    sw ra, 0(sp)
    sw s1, 4(sp)
    sw s2, 8(sp)
    sw s3, 12(sp)
    sw s4, 16(sp)

    li t0, 0 # contador de iteracoes
    lw t1, n_points 
    la t2, points # endereco do vetor de pontos
    la s1, clusters # endereco do vetor de clusters
    la s2, media_points
    li s3, 12
    li s4, 0

somaCoordenadas:
    lw t3, 0(t2) # x
    lw t4, 4(t2) # y
    lw t5, 0(s1) # ver a que cluster o ponto pertence
    mul t5, t5, s3 # indice de cluster x 12
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
    blt t0, t1, somaCoordenadas # numero de iteracoes < n_points
    
    li t0, 0
    lw t4, k
    la s1, centroids

calculaMedia:
    lw t1, 0(s2) # Soma das coordenadas x
    lw t2, 4(s2) # Soma das coordenadas y
    lw t3, 8(s2) # Numero de pontos
    beq t3, x0, novoCentroide
    div t1, t1, t3
    div t2, t2, t3
    
comparaCentroids:
    lw t5, 0(s1)
    lw t6, 4(s1)
    bne t1, t5, centroidesAlterados
    bne t2, t6, centroidesAlterados
    
guardaCentroid:
    sw t1, 0(s1)
    sw t2, 4(s1)
    addi s1, s1, 8
    addi s2, s2, 12
    
    # print
    la a0, coordenadas_centroid
    li a7, 4
    ecall
    mv a0, t0 # indice do centroide
    li a7, 1
    ecall
    la a0, nova_linha
    li a7, 4
    ecall
    mv a0, t1 # x
    li a7, 1
    ecall
    la a0, separador
    li a7, 4
    ecall
    mv a0, t2 # y
    li a7, 1
    ecall
    la a0, nova_linha
    li a7, 4
    ecall
    
    addi t0, t0, 1
    blt t0, t4, calculaMedia # se indice de centroide < k
    mv a0, s4
    jal limpaMediaPoints
    lw s4, 16(sp)
    lw s3, 12(sp)
    lw s2, 8(sp)
    lw s1, 4(sp)
    lw ra, 0(sp)
    addi sp, sp, 20
    jr ra 
    
centroidesAlterados:
    li s4, 1
    j guardaCentroid
    
novoCentroide:
    # print
    la a0, nova_inicializacao
    li a7, 4
    ecall
    mv a0, t0
    li a7, 1
    ecall
    la a0, nova_linha
    li a7, 4
    ecall
    
    jal initializeOneCentroide
    mv t1, a0 # x
    mv t2, a1 # y
    j comparaCentroids
    
### limpaMediaPoints
# Argumentos: nenhum
# Retorno: nenhum

limpaMediaPoints:
    la t0, media_points
    lw t1, k
    li t2, 3
    mul t1, t1, t2
    li t2, 0
    
limpaMediaPoints_loop:
    sw t2, 0(t0)
    addi t0, t0, 4
    addi t1, t1, -1
    bgt t1, x0, limpaMediaPoints_loop
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
    sub t0, a0, a2 # x0-x1
    sub t1, a1, a3 # y0-y1
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
    lw s1, k 
    li s4, 0 # Iterador
    
    li s2, LED_MATRIX_WIDTH
    li s3, LED_MATRIX_HEIGHT
    add s2, s2, s3  # Guarda a maior distancia possivel
    
    li s3, 0 # indice do cluster mais proximo
    mv t6, a0 # guardar x do ponto
    
calculaManhattanDistance:
    mv a0, t6
    lw a2, 0(s0) # x do centroide
    lw a3, 4(s0) # y do centroide
    addi s0, s0, 8 # Passa para o proximo centroide
    jal manhattanDistance 
    
    blt a0, s2, updateMenorDistancia
        
terminaNearestCluster:
    addi s4, s4, 1
    blt s4, s1, calculaManhattanDistance
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
    mv s2, a0 # Guardar menor distancia
    mv s3, s4 # Guardar indice do centroide mais proximo
    j terminaNearestCluster
    
### initializeCentroids
# Argumentos: nenhum
# Retorno: nenhum
 
initializeCentroids:
    addi sp, sp, -4
    sw ra, 0(sp)
    
    li t0, 0 # indice do cluster
    la t1, centroids
    lw t2, k
    
    la a0, centroides_iniciais
    li a7, 4
    ecall
    la a0, nova_linha
    li a7, 4
    ecall
    
initializeCentroids_loop:
    # print
    la a0, coordenadas_centroid
    li a7, 4
    ecall
    mv a0, t0
    li a7, 1
    ecall
    la a0, nova_linha
    li a7, 4
    ecall
    
    jal initializeOneCentroide
    sw a0, 0(t1) 
    sw a1, 4(t1)
    addi t1, t1, 8
    addi t0, t0, 1
    blt t0, t2, initializeCentroids_loop
    
    lw ra, 0(sp)
    addi sp, sp, 4
    jr ra
    
    
### initializeOneCentroide
# Argumentos: nenhum
# Retorno: 
# a0: x 
# a1: y

initializeOneCentroide:
    addi sp, sp, -8
    sw s1, 0(sp)
    sw s2, 4(sp)
    
    li a7, 30
    ecall
    andi s2, a0, 0x1F
    #li s1, 32
    #remu s2, a0, s1
    li a7, 30
    ecall
    andi a1, a0, 0x1F
    #remu a1, a0, s1
    
    # print
    mv a0, s2
    li a7, 1
    ecall
    la a0, separador
    li a7, 4
    ecall
    mv a0, a1
    li a7, 1
    ecall
    la a0, nova_linha
    li a7, 4
    ecall
    
    mv a0, s2
    lw s1, 0(sp)
    lw s2, 4(sp)
    addi sp, sp, 8
    
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
    li s1, 0 # iterador para comparar com L
    lw s2, L # iterador do numero de pontos
    li s3, 1 # verificar se nao houve alteracoes nos centroides
    addi sp, sp, -4
    sw ra, 0(sp)
    jal initializeCentroids
    
mainKMeansIteration:
    beq s3, x0, terminaMainKMeans # Se centroides nao mudarem, terminar
    jal cleanScreen
    jal calculateClusters
    jal printClusters
    jal printCentroids
    jal calculateCentroids # Calcular novo vetor de centroides
    mv s3, a0 
    jal printClusters
    jal printCentroids
    addi s1, s1, 1
    blt s1, s2, mainKMeansIteration
    
terminaMainKMeans:
    la a0, numero_iteracoes
    li a7, 4
    ecall
    li a7 1
    mv a0, s1
    ecall 
    lw ra, 0(sp)
    addi sp, sp, 4
    jr ra
    