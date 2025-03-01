###############################################################################################################################################################################

########################################################################
#===== Ensure that Perseus is within same folder as the main code =====#
########################################################################



Resilience_Attacks2 = function(attack = c("node", "edge"),  graph_type = c("weighted", "unweighted") , analysis = c("Motifs", "TDA", "Conv_Small", "Connectivity Loss"), type = c("degree", "betweeness", "strength" , "weight_hier", "E_betweeness"), net_val, frac_val){
  
  
  #=== TDA necessities ===#
  
  cap = 3 # dimension cap
  delta = 0.10
  filt_len = 100
  
  
  frac_len = length(frac_val)
  network = net_val
  
  network_org = network
  
  deg = degree(network_org)
  d_ord = length(deg)
  deg_org = order(deg, decreasing = T)
  
  bet = betweenness(network_org)
  b_ord = length(bet)
  bet_org = order(bet, decreasing = T)
  
  e_bet = edge_betweenness(network_org)
  eb_ord = length(e_bet)
  ebet_org = order(e_bet, decreasing = T)
  
  if(graph_type == "weighted"){
    
    str_vals = strength(network_org)
    s_ord = length(str_vals)
    str_ord = order(str_vals, decreasing = T)
    
    ed_val = E(network_org)$weight
    ed_ord = length(ed_val)
    edge_org = order(ed_val, decreasing = T)
  }else{
    str_vals = ed_val = c()
  }
  
  
  n1 = n2 = numeric(frac_len)
  V_1 = V_2 = V_3 = V_4 = V_5 = V_6 = Tot_V = numeric(frac_len)
  C_V1 = C_V2 = C_V3 = C_V4 = C_V5 = C_V6 = numeric(frac_len)
  
  GC = CLUS = DIAM = APL = numeric(frac_len)
  
  betti_0 = betti_1 = wasser_dist_01 = fin =c()
  
  
  ########################
  ##### NODE ATTACKS #####
  ########################
  
  
  if(attack == "node"){
    
    # 1. Motif Analysis Strategy #
    if(analysis == "Motifs"){
      
      
      for (i in 1:(frac_len + 1)){ 
        
        
        #------ Motif size = 4 -------#
        m2 = motifs(network, 4)
        m2[is.na(m2)]  =  0
        
        n02 = count_motifs(network, 4)
        n2[i] =  n02
        
        V_1[i] = m2[5]  
        V_2[i] = m2[7] 
        V_3[i] = m2[8] 
        V_4[i] = m2[9]   
        V_5[i] = m2[10] 
        V_6[i] = m2[11]  
        
        Tot_V[i] = sum(m2[5],m2[7],m2[8],m2[9],m2[10],m2[11])
        #-------------------------------------------------#
        
        if (type == "degree") #===== Degree - Based Attacks =====# 
        {
          if (i <= frac_len)
          {
            nodes_to_delete = V(network_org)[deg_org[1:round(d_ord*frac_val[i])]]
            network = delete_vertices(network_org, nodes_to_delete)
            
          }
          
        }
        
        else if (type == "betweeness") #===== Betweeness centrality - Based Attacks =====# 
        {
          if (i <= frac_len)
          {
            nodes_to_delete = V(network_org)[bet_org[1:round(b_ord*frac_val[i])]]
            network = delete_vertices(network_org, nodes_to_delete)    
          }
          
        }
        
        else if (type == "strength") #===== Betweeness centrality - Based Attacks =====# 
        {
          if (i <= frac_len)
          {
            nodes_to_delete = V(network_org)[str_ord[1:round(s_ord*frac_val[i])]]
            network = delete_vertices(network_org, nodes_to_delete)    
          }
          
        }
        
        
      }
      
      
      n22 = n2[1]
      
      C_V1 = V_1/n22; C_V1[is.na(C_V1)] = 0
      C_V2 = V_2/n22; C_V2[is.na(C_V2)] = 0
      C_V3 = V_3/n22; C_V3[is.na(C_V3)] = 0 
      C_V4 = V_4/n22; C_V4[is.na(C_V4)] = 0
      C_V5 = V_5/n22; C_V5[is.na(C_V5)] = 0
      
      
      resultsN= data.frame( c(0,frac_val),Tot_V,V_1,V_2,V_3,V_4,V_5,C_V1,C_V2,C_V3,C_V4,C_V5)
      #resultsN= data.frame(c(0,frac_val),C_V1,C_V2,C_V3,C_V4,C_V5)
      
      #return(resultsN)
      
      
      
    }
    
    
    # 2. TDA Strategy #
    else if(analysis == "TDA") 
    {
      
        for (i in 1:(frac_len + 1)){ 
          
          
          A1 =  get.adjacency(network, attr="weight")
          A2 = as.matrix(A1)
          
          A2[A2==0] = 999
          diag(A2)=0
          
          
          d = length(V(network))
          print(i)
          
          # writing data into file M.txt
          cat(d,file='M.txt',append=F,sep = '\n')
          cat(paste(0,delta,filt_len,cap,sep = ' '),file = 'M.txt',append = T,sep = '\n') 
          cat(A2,file='M.txt',append = T) 
          
          system('perseusWin.exe distmat M.txt Moutput')
          
          # read Betti numbers from file Moutput_betti.txt
          
          betti_data = as.matrix(read.table('Moutput_betti.txt'))
          betti_index = setdiff(0:filt_len,betti_data[,1])
          
          for (k in betti_index) 
            if (k < length(betti_data[ ,1])) 
            {
              betti_data = rbind(betti_data[1:k, ], betti_data[k,], betti_data[(k+1):length(betti_data[,1]), ])
              betti_index = betti_index + 1
            } else
              betti_data = rbind(betti_data[1:k,], betti_data[k,])
          
          betti_0 = rbind(betti_0, betti_data[,2])
          betti_1 = rbind(betti_1, betti_data[,3])
          
          
          # read birth and death times for each dimension
          
          # dim = 0
          persist_data = as.matrix(read.table('Moutput_0.txt'))
          persist_data[persist_data[,2] == -1, 2] = filt_len + 1
          persist_data = persist_data/(filt_len + 1)
          P = cbind(rep(0, nrow(persist_data)), persist_data)
          
          # dim = 1
          if (file.info('Moutput_1.txt')$size>0)
          { 
            persist_data = as.matrix(read.table('Moutput_1.txt', blank.lines.skip = T))
            persist_data[persist_data[,2] == -1, 2] = filt_len + 1
            persist_data = persist_data/(filt_len + 1)
            P = rbind(P, cbind(rep(1, nrow(persist_data)), persist_data))
            
          }
          
          if (i == 1) P_org = P  
          
          wasser_dist_01 = c(wasser_dist_01, wasserstein(P_org, P, dimension = c(0,1)))
          
          
          if (type == "degree") #===== Degree - Based Attacks =====# 
          {
            if (i <= frac_len)
            {
              nodes_to_delete = V(network_org)[deg_org[1:round(d_ord*frac[i])]]
              network = delete_vertices(network_org, nodes_to_delete)
              
            }
            
          }
          
          else if (type == "betweeness") #===== Betweeness centrality - Based Attacks =====# 
          {
            if (i <= frac_len)
            {
              nodes_to_delete = V(network_org)[bet_org[1:round(b_ord*frac[i])]]
              network = delete_vertices(network_org, nodes_to_delete)    
            }
            
          }
          
          else if (type == "strength") #===== Betweeness centrality - Based Attacks =====# 
          {
            if (i <= frac_len)
            {
              nodes_to_delete = V(network_org)[str_ord[1:round(s_ord*frac[i])]]
              network = delete_vertices(network_org, nodes_to_delete)    
            }
            
          }
          
          
          
        }
        
      
      
      
      norm_const0 = norm(as.matrix(betti_0[1,]), type = '2')
      betti_0_DistS = as.matrix(dist(betti_0))/norm_const0
      
      norm_const1 = norm(as.matrix(betti_1[1,]),type = '2')
      betti_1_DistS = as.matrix(dist(betti_1))/norm_const1
      
      resultsN = data.frame( c(0, frac_val), betti_0_DistS[1,], betti_1_DistS[1,], wasser_dist_01)
      
    }
    
    
    
    # 3. Giant Component Analysis #
    else if (analysis == "Conv_Small")
    {
      for (i in 1:(frac_len + 1)){ 
        
        
        #------ Small world properties  -------#
        compts = components(network)    #largest Connected components/Giant component 
        GC[i] = max(compts$csize) 
        
        CLUS[i] = transitivity(network) # Clustering Coefficient
        DIAM[i] = diameter(network) # Diameter
        APL[i] = average.path.length(network) # Average path length
        
        
        #-------------------------------------------------#
        
        if (type == "degree") #===== Degree - Based Attacks =====# 
        {
          if (i <= frac_len)
          {
            nodes_to_delete = V(network_org)[deg_org[1:round(d_ord*frac_val[i])]]
            network = delete_vertices(network_org, nodes_to_delete)
            
          }
          
        }
        
        else if (type == "betweeness") #===== Betweeness centrality - Based Attacks =====# 
        {
          if (i <= frac_len)
          {
            nodes_to_delete = V(network_org)[bet_org[1:round(b_ord*frac_val[i])]]
            network = delete_vertices(network_org, nodes_to_delete)    
          }
          
        }
        
        else if (type == "strength") #===== Betweeness centrality - Based Attacks =====# 
        {
          if (i <= frac_len)
          {
            nodes_to_delete = V(network_org)[str_ord[1:round(s_ord*frac_val[i])]]
            network = delete_vertices(network_org, nodes_to_delete)    
          }
          
        }
        
        
        
      }
      
      
      resultsN = data.frame(c(0,frac_val),GC,APL, CLUS, DIAM)
    }
    
    # 4. Loss Connectivity #
    else if (analysis == "Connectivity Loss")
    {
      # 
      # dist <- distances(network)
      # dist[dist == Inf] <- 0
      # dist[dist > 0] <- 1
      # tot <- sum(dist)
      # 
      # g2 <- network
      
      
      # ---------------------------------------------------------------------#
      for(i in 1:(frac_len+1)){ 
        
        dist2 <- distances(network)
        dist2[dist2 == Inf] <- 0
        dist2[dist2 > 0] <- 1
        tot2 <- sum(dist2)
        if(i == 1){tot = tot2}
        fin[i] <- tot - tot2
        
        
        
        
        if (type == "degree") #===== Degree - Based Attacks =====# 
        {
          if (i <= frac_len)
          {
            nodes_to_delete = V(network_org)[deg_org[1:round(d_ord*frac_val[i])]]
            network = delete_vertices(network_org, nodes_to_delete)
            
          }
          
        }
        
        else if (type == "betweeness") #===== Betweeness centrality - Based Attacks =====# 
        {
          if (i <= frac_len)
          {
            nodes_to_delete = V(network_org)[bet_org[1:round(b_ord*frac_val[i])]]
            network = delete_vertices(network_org, nodes_to_delete)    
          }
          
        }
        
        else if (type == "strength") #===== Betweeness centrality - Based Attacks =====# 
        {
          if (i <= frac_len)
          {
            nodes_to_delete = V(network_org)[str_ord[1:round(s_ord*frac_val[i])]]
            network = delete_vertices(network_org, nodes_to_delete)    
          }
          
        }
        
        
      }
      
      fin = fin/tot
      resultsN = data.frame(c(0,frac_val), fin)
      
    }
    
    
  }
  
  
  
  ########################
  ##### EDGE ATTACKS #####
  ########################
  
  else if(attack == "edge"){
    
    # 1. Motif Analysis Strategy #
    
    if(analysis == "Motifs") 
    {
      
      
      for (i in 1:(frac_len + 1)){ 
        
        
        #------ Motif size = 4 -------#
        m2 = motifs(network, 4)
        m2[is.na(m2)]  =  0
        
        n02 = count_motifs(network, 4)
        n2[i] =  n02
        
        V_1[i] = m2[5]  
        V_2[i] = m2[7] 
        V_3[i] = m2[8] 
        V_4[i] = m2[9]   
        V_5[i] = m2[10] 
        V_6[i] = m2[11]  
        
        Tot_V[i] = sum(m2[5],m2[7],m2[8],m2[9],m2[10],m2[11])
        #-------------------------------------------------#
        
        if (type == "weight_hier") #===== Degree - Based Attacks =====# 
        {
          if (i <= frac_len)
          {
            edges_to_delete = E(network_org)[edge_org[1:round(ed_ord*frac_val[i])]]
            network = delete_edges(network_org, edges_to_delete)
            
          }
          
        }
        
        else if (type == "E_betweeness") #===== Betweeness centrality - Based Attacks =====# 
        {
          if (i <= frac_len)
          {
            edges_to_delete = E(network_org)[ebet_org[1:round(eb_ord*frac_val[i])]]
            network = delete_edges(network_org, edges_to_delete)    
          }
          
        }
        
        
        
      }
      
      n22 = n2[1]
      
      C_V1 = V_1/n22; C_V1[is.na(C_V1)] = 0
      C_V2 = V_2/n22; C_V2[is.na(C_V2)] = 0
      C_V3 = V_3/n22; C_V3[is.na(C_V3)] = 0 
      C_V4 = V_4/n22; C_V4[is.na(C_V4)] = 0
      C_V5 = V_5/n22; C_V5[is.na(C_V5)] = 0
      
      
      resultsN = data.frame(c(0,frac_val),Tot_V,V_1,V_2,V_3,V_4,V_5,C_V1,C_V2,C_V3,C_V4,C_V5)
      #resultsN = data.frame(c(0,frac_val),C_V1,C_V2,C_V3,C_V4,C_V5)
      #colnames(resultsN) = c("iter","fr", "Tot_V", "V1", "V2", "V3", "V4", "V5", "C_V1", "C_V2", "C_V3", "C_V4", "C_V5")
      
    }
    
    
    # 2. TDA Strategy #
    
    else if(analysis == "TDA") 
    {
        for (i in 1:(frac_len + 1)){ 
          
          A1 =  get.adjacency(network, attr="weight")
          A2 = as.matrix(A1)
          
          A2[A2==0] = 999
          diag(A2)=0
          
          
          d = length(V(network))
          print(i)
          
          # writing data into file M.txt
          cat(d,file = 'M.txt',append=F,sep = '\n')
          cat(paste(0,delta,filt_len,cap,sep = ' '),file = 'M.txt',append = T,sep = '\n') 
          cat(A2,file = 'M.txt',append = T) 
          
          system('perseusWin.exe distmat M.txt Moutput')
          
          # read Betti numbers from file Moutput_betti.txt
          
          betti_data = as.matrix(read.table('Moutput_betti.txt'))
          betti_index = setdiff(0:filt_len,betti_data[,1])
          
          for (k in betti_index) 
            if (k < length(betti_data[ ,1])) 
            {
              betti_data = rbind(betti_data[1:k, ], betti_data[k,], betti_data[(k+1):length(betti_data[,1]), ])
              betti_index = betti_index + 1
            } else
              betti_data = rbind(betti_data[1:k,], betti_data[k,])
          
          betti_0 = rbind(betti_0, betti_data[,2])
          betti_1 = rbind(betti_1, betti_data[,3])
          
          # read birth and death times for each dimension
          
          # dim = 0
          persist_data = as.matrix(read.table('Moutput_0.txt'))
          persist_data[persist_data[,2] == -1, 2] = filt_len + 1
          persist_data = persist_data/(filt_len + 1)
          P = cbind(rep(0, nrow(persist_data)), persist_data)
          
          # dim = 1
          if (file.info('Moutput_1.txt')$size>0)
          { 
            persist_data = as.matrix(read.table('Moutput_1.txt', blank.lines.skip = T))
            persist_data[persist_data[,2] == -1, 2] = filt_len + 1
            persist_data = persist_data/(filt_len + 1)
            P = rbind(P, cbind(rep(1, nrow(persist_data)), persist_data))
            
          }
          
          if (i == 1) P_org = P  
          
          wasser_dist_01 = c(wasser_dist_01, wasserstein(P_org, P, dimension = c(0,1)))
          
          
          if (type == "weight_hier") #===== Degree - Based Attacks =====# 
          {
            if (i <= frac_len)
            {
              edges_to_delete = E(network_org)[edge_org[1:round(ed_ord*frac_val[i])]]
              network = delete_edges(network_org, edges_to_delete)
              
            }
            
          }
          
          else if (type == "E_betweeness") #===== Betweeness centrality - Based Attacks =====# 
          {
            if (i <= frac_len)
            {
              edges_to_delete = E(network_org)[ebet_org[1:round(eb_ord*frac_val[i])]]
              network = delete_edges(network_org, edges_to_delete)    
            }
            
          }
          
        }
        
      
      
    
      norm_const0 = norm(as.matrix(betti_0[1,]), type = '2')
      betti_0_DistS = as.matrix(dist(betti_0))/norm_const0
      
      norm_const1 = norm(as.matrix(betti_1[1,]),type = '2')
      betti_1_DistS = as.matrix(dist(betti_1))/norm_const1
      
      resultsN = data.frame(c(0, frac), betti_0_DistS[1,], betti_1_DistS[1,], wasser_dist_01) 
      #colnames(resultsN) = c("iter","fr", "betti_0", "betti_1")
      
    }
    
    
    
    # 3. Giant Component Analysis #
    else if (analysis == "Conv_Small")
    {
      
      for (i in 1:(frac_len + 1)){ 
        
        
        #------ Small world properties  -------#
        compts = components(network)    #largest Connected components/Giant component 
        GC[i] = max(compts$csize) 
        
        CLUS[i] = transitivity(network) # Clustering Coefficient
        DIAM[i] = diameter(network) # Diameter
        APL[i] = average.path.length(network) # Average path length
        
        #-------------------------------------------------#
        
        if (type == "weight_hier") #===== Degree - Based Attacks =====# 
        {
          if (i <= frac_len)
          {
            edges_to_delete = E(network_org)[edge_org[1:round(ed_ord*frac_val[i])]]
            network = delete_edges(network_org, edges_to_delete)
            
          }
          
        }
        
        else if (type == "E_betweeness") #===== Betweeness centrality - Based Attacks =====# 
        {
          if (i <= frac_len)
          {
            edges_to_delete = E(network_org)[ebet_org[1:round(eb_ord*frac_val[i])]]
            network = delete_edges(network_org, edges_to_delete)    
          }
          
        }
        
        
      }
      
      
      resultsN = data.frame(c(0,frac_val),GC,APL, CLUS, DIAM)
    }
    
    
    # 4. Loss Connectivity #
    else if (analysis == "Connectivity Loss")
    {
      # 
      # dist <- distances(network)
      # dist[dist == Inf] <- 0
      # dist[dist > 0] <- 1
      # tot <- sum(dist)
      # 
      # g2 <- network
      
      
      #---------------------------------------------------------------------#
      for(i in 1:(frac_len+1)){ 
        
        
        dist2 <- distances(network)
        dist2[dist2 == Inf] <- 0
        dist2[dist2 > 0] <- 1
        tot2 <- sum(dist2)
        if(i == 1){tot = tot2}
        fin[i] <- tot - tot2
        
        #-------------------------------------------------#
        
        if (type == "weight_hier") #===== Degree - Based Attacks =====# 
        {
          if (i <= frac_len)
          {
            edges_to_delete = E(network_org)[edge_org[1:round(ed_ord*frac_val[i])]]
            network = delete_edges(network_org, edges_to_delete)
            
          }
          
        }
        
        else if (type == "E_betweeness") #===== Betweeness centrality - Based Attacks =====# 
        {
          if (i <= frac_len)
          {
            edges_to_delete = E(network_org)[ebet_org[1:round(eb_ord*frac_val[i])]]
            network = delete_edges(network_org, edges_to_delete)    
          }
          
        }
        
        
      }
      
      fin = fin/tot
      resultsN = data.frame(c(0,frac_val), fin)
      
    }
    
  }
  
  
  return(resultsN)
  
}


###############################################################################################################################################################################
