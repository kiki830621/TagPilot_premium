#' Confusin Matrix Function
#'
#' Brief description of what this function does
#'
#' @param params Description of parameters
#' @return Description of return value
#'
#' @examples
#' confusin_matrix()


confusin_matrix <- function(data,item_col="ASIN",customer_col="customer_id",tim_col="time"){
  setDT(data)
  sub_d <- data[,.(ITEM=get(item_col),cus=get(customer_col),time=get(tim_col))] 
  Counting <- sub_d[,.(Count=.N),by=cus]
  focus_cus <- Counting[Count>1]$cus 
  sub_d <- sub_d[cus %in%focus_cus]
  item_name <- unique(sub_d$ITEM)
  item_length <- length(item_name)
  Confusin_matrix <- matrix(0,item_length,item_length)
  pb <- progress_bar$new(
    format = "[:bar] :current/:total (:percent) :elapsed | ETA: :eta",
    total = item_length,  # 這裡假設你有100個步驟
    clear = FALSE,  # 讓進度條不會被清除
    width = 60
  )
  
  
  print("Start construction matrix")
  for (i in 1:item_length) {
    before_item <- item_name[i]
    for (j in 1:item_length) {
      after_item <- item_name[j]
      # 定義第一個和第二個 ASIN
      
      # 建立一個新的欄位來檢查同一個客戶是否按順序購買了 asin1 和 asin2
      sub_d[, next_item := shift(ITEM, type = "lead"), by = cus]
      
      # 選出購買 asin1 且下一筆是 asin2 的情況
      Confusin_matrix[i,j] <- sub_d[ITEM == before_item & next_item == after_item, .N]
      
    }
    pb$tick()  # 每次迴圈都更新進度條
  }
  rowSums(Confusin_matrix)
  
  row_sums <- rowSums(Confusin_matrix)
  
  zero_row <- row_sums == 0  # 判斷哪些行的和為 0  avoid singularity issue
  
  # 使用 sweep 函數對非零的行執行除法操作
  normalized_mat <- sweep(Confusin_matrix, 1, row_sums, "/")
  normalized_mat[zero_row,] <- 0
  #normalized_mat[non_zero_rows, ] <- sweep(Confusin_matrix[non_zero_rows, ], 1, row_sums[non_zero_rows], "/")
  
  
  
  # 使用 sweep 函數來將矩陣中的每個元素除以該行的行和
  #  normalized_mat <- sweep(Confusin_matrix, 1, row_sums, "/")
  colnames(normalized_mat) <- item_name
  row.names(normalized_mat) <- item_name
  return(normalized_mat)
  
}



# Next_item_selection <- function(Matrix,Previous_item,echo=T){
#   
#   
#   selec_prob <- Matrix[  which(row.names(Matrix)==Previous_item),]
#   max_loc <- which.max(selec_prob)
#   Best_cnadidate <- names(selec_prob)[max_loc]
#   p_hat <- selec_prob[max_loc]
#   if (echo) print(paste0("Conditional probaiblity: ",round(p_hat,3)))
#   return(Best_cnadidate)
# }
# 




Next_item_selection <- function(Matrix, Previous_item, set_size = 1, echo = TRUE) {
  
  # 找到對應的機率向量
  selec_prob <- Matrix[which(row.names(Matrix) == Previous_item), ]
  
  # 將機率由大到小排序，選出前 set_size 個最高機率的索引
  top_locs <- order(selec_prob, decreasing = TRUE)[1:set_size]
  
  # 取得對應的 ASIN 名稱及機率
  Best_candidates <- names(selec_prob)[top_locs]
  p_hats <- selec_prob[top_locs]
  
  # 顯示條件機率（可選）
  if (echo) {
    for (i in seq_along(Best_candidates)) {
      print(paste0("Conditional probability of ", Best_candidates[i], ": ", round(p_hats[i], 3)))
    }
  }
  
  # 回傳前 set_size 個 ASIN 名稱
  return(Best_candidates)
}


