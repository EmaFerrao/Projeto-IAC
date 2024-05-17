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
centroids:   .word 0,0
k:           .word 1

# Valores de centroids, k e L a usar na 2a parte do prejeto:
#centroids:   .word 0,0, 10,0, 0,10
#k:           .word 3
#L:           .word 10

# Abaixo devem ser declarados o vetor clusters (2a parte) e outras estruturas de dados
# que o grupo considere necessarias para a solucao:
#clusters:    




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
    jal mainSingleCluster

    # Descomentar na 2a parte do projeto:
    #jal mainKMeans
    
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
    li t2, LED_MATRIX_WIDTH
    li t3, LED_MATRIX_HEIGHT
    la t4, points
    lw t5, n_points
    lw a2, green 
    addi sp, sp, -4
    sw ra, 0(sp)

itera:
    lw t0, 0(t4)
    lw t1, 4(t4)
    addi t4, t4, 8
    mv a0, t0
    mv a1, t1
    jal printPoint 
    addi t5, t5, -1
    bgt t5, x0, itera
    
    lw ra, 0(sp)
    addi sp, sp, 4
    
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
    
executaPrintCentroids:
    lw a0, 0(t1)
    lw a1, 4(t1)
    li a2, green
    addi t1, t1, 8
    addi sp, sp, -4
    sw ra, 0(sp)
    jal printPoint
    lw ra, 0(sp)
    addi sp, sp, 4
    addi t0, t0, -1
    bgt t0, x0, executaPrintCentroids
    jr ra
    

### calculateCentroids
# Calcula os k centroides, a partir da distribuicao atual de pontos associados a cada agrupamento (cluster)
# Argumentos: nenhum
# Retorno: nenhum

calculateCentroids:
    li t0, 0 # contador de iteracoes
    li t5, 0 # soma das coordenadas x
    li t6, 0 # soma das coordenadas y
    lw t1, n_points 
    la t2, points # endereco do vetor de pontos
    la s3, centroids # endereco do vetor de centroides

somaCoordenadas:
    lw t3, 0(t2)
    lw t4, 4(t2)
    add t5, t5, t3
    add t6, t6, t4
    addi t2, t2, 8
    addi t0, t0, 1
    blt t0, t1, somaCoordenadas

calculaMedia:
    div t5, t5, t1
    div t6, t6, t1
    sw t5, 0(s3)
    sw t6, 4(s3)
    
    la a0, calcula_centroid
    li a7, 4
    ecall
    mv a0, t5
    li a7, 1
    ecall
    la a0, separador
    li a7, 4
    ecall
    mv a0, t6
    li a7, 1
    ecall
    la a0, nova_linha
    li a7, 4
    ecall
    jr ra

### mainSingleCluster
# Funcao principal da 1a parte do projeto.
# Argumentos: nenhum
# Retorno: nenhum

mainSingleCluster:

    #1. Coloca k=1 (caso nao esteja a 1)
    lw s2, k

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
    #Load
    add t0, x0, a0  
    add t1, x0, a1 
    add t2, x0, a2  
    add t3, x0, a3 
    
    #x0-y0
    #x1-y1
    sub t4, t0, t1 
    sub t5, t2, t3
    
    #valores absoluto
    li t1, -1
    add t0, x0, t4
    srli t0, t0, 31
    mul t0, t0, t1
    mul t4, t0, t4
    
    add t0, x0, t5
    srli t0, t0, 31
    mul t0, t0, t1
    mul t5, t0, t5
    
    #d = |x0-y0| + |x1-y1|
    add t0, t4, t5
    add a0, x0, t0
    
    jr ra


### nearestCluster
# Determina o centroide mais perto de um dado ponto (x,y).
# Argumentos:
# a0, a1: (x, y) point
# Retorno:
# a0: cluster index

nearestCluster:
    la t0, centroids # Endereco do vetor de centroides
    li t1, 0 # Contador de iteracoes
    
    # Inicializar a width + height
    li t2, LED_MATRIX_WIDTH
    li t3, LED_MATRIX_HEIGHT
    add t2, t2, t3  # Guarda a maior distancia possivel
    
    # Inicializar o indice da menor distancia
    li t3, 0
    
    addi sp, sp, -4 # Guardar ra no stack
    sw ra, 0(sp)
    
calculaManhattanDistance:
    lw a2, 0(t0) # Colocar os valores nos resgistos necessarios
    lw a3, 4(t0) # para calcular a manhattan distance
    addi t0, t0, 8 # Passa para o proximo centroide
    jal manhattanDistance # Calcular manhattan distance
    
    ### Calcular menor distancia ###
    blt a0, t2, updateMenorDistancia
        
terminaNearestCluster:
    addi t1, t1, 1 # Incrementa iterador
    blt t1, s2, calculaManhattanDistance
    mv a0, t3
    lw ra, 0(sp)
    addi sp, sp, 4
    jr ra
    
updateMenorDistancia:
    # Alterar menor distancia
    mv t2, a0
    # Alterar indice do cluster
    mv t3, t1
    j terminaNearestCluster

### mainKMeans
# Executa o algoritmo *k-means*.
# Argumentos: nenhum
# Retorno: nenhum

mainKMeans:  
    # POR IMPLEMENTAR (2a parte)
    jr ra