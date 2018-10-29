install.packages("pryr")
library(pryr) # for memory debugging

memory.limit() # memory.limit(size=4000) 
memory.size()
memory.size(max=TRUE)
pryr::mem_used()
gc(verbose=TRUE)





data.table::tables() # shows list of created datables
ls() # show all the objests
object.size(datable)
rm(FXRatesCHF) # delete the objects
gc() # garbage collection make sure memory occupied by cleared objects is made available (should go after "rm()")
