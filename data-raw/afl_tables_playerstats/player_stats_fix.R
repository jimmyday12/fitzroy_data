library(fitzRoy)
library(dplyr)

dat <- get_afltables_stats(start_date = "1897-05-01")

# Tony's fixes
# Fix Arthur Davidson (recorded as Alex Davidson)
dat$ID[dat$ID == 4350 & dat$Playing.for == "Fitzroy" & dat$Season == 1898 & dat$Round %in% c(7,10)] = 15000
dat$First.name[dat$ID == 4350 & dat$Playing.for == "Fitzroy" & dat$Season == 1898 & dat$Round %in% c(7,10)] = "Arthur"
dat$Surname[dat$ID == 4350 & dat$Playing.for == "Fitzroy" & dat$Season == 1898 & dat$Round %in% c(7,10)] = "Davidson"

# Fix George McLeod (there were two)
dat$ID[dat$First.name == "George" & dat$Surname == "McLeod" & dat$Playing.for == "St Kilda" & dat$Season == 1903] = 15001

# Fix Archie Richardson (three different guys)
dat$ID[dat$First.name == "Archie" & dat$Surname == "Richardson" &
         dat$Playing.for == "St Kilda" & dat$Season == 1898] = 15002
dat$First.name[dat$First.name == "Archie" & dat$Surname == "Richardson" &
                 dat$Playing.for == "St Kilda" & dat$Season == 1898] = "Mr"
dat$Surname[dat$First.name == "Archie" & dat$Surname == "Richardson" &
              dat$Playing.for == "St Kilda" & dat$Season == 1898] = "Richardson"

dat$ID[dat$First.name == "Archie" & dat$Surname == "Richardson" &
         dat$Playing.for == "St Kilda" & dat$Season == 1900] = 15003
dat$First.name[dat$First.name == "Archie" & dat$Surname == "Richardson" &
                 dat$Playing.for == "St Kilda" & dat$Season == 1900] = "William"
dat$Surname[dat$First.name == "Archie" & dat$Surname == "Richardson" &
              dat$Playing.for == "St Kilda" & dat$Season == 1900] = "Richardson"

dat$ID[dat$First.name == "Archie" & dat$Surname == "Richardson" &
         dat$Playing.for == "St Kilda" & dat$Season == 1901] = 15004
dat$First.name[dat$First.name == "Archie" & dat$Surname == "Richardson" &
                 dat$Playing.for == "St Kilda" & dat$Season == 1901] = "Alfred"
dat$Surname[dat$First.name == "Archie" & dat$Surname == "Richardson" &
              dat$Playing.for == "St Kilda" & dat$Season == 1901] = "Richardson"

# Fix Jack Dorgan (recorded as Jim Dorgan)
dat$ID[dat$First.name == "Jim" & dat$Surname == "Dorgan" & dat$Season == 1949] = 15005
dat$First.name[dat$First.name == "Jim" & dat$Surname == "Dorgan" & dat$Season == 1949] = "Jack"
dat$Surname[dat$First.name == "Jim" & dat$Surname == "Dorgan" & dat$Season == 1949] = "Dorgan"

# Fix Walter Johnston (recorded as Alex Johnston)
dat$ID[dat$First.name == "Alex" & dat$Surname == "Johnston" &
         dat$Playing.for == "Richmond" & dat$Season == 1908 & dat$Round == 8] = 15006
dat$First.name[dat$First.name == "Alex" & dat$Surname == "Johnston" &
                 dat$Playing.for == "Richmond" & dat$Season == 1908 & dat$Round == 8] = "Walter"
dat$Surname[dat$First.name == "Alex" & dat$Surname == "Johnston" &
              dat$Playing.for == "Richmond" & dat$Season == 1908 & dat$Round == 8] = "Johnston"

# Fix Jim and Tom Darcy (recorded only as Jim)
dat$ID[dat$First.name == "Jim" & dat$Surname == "Darcy" &
         dat$Playing.for == "Sydney" & dat$Season == 1904 & dat$Round == 17] = 15007
dat$First.name[dat$First.name == "Jim" & dat$Surname == "Darcy" &
                 dat$Playing.for == "Sydney" & dat$Season == 1904 & dat$Round == 17] = "Tom"
dat$Surname[dat$First.name == "Jim" & dat$Surname == "Darcy" &
              dat$Playing.for == "Sydney" & dat$Season == 1904 & dat$Round == 17] = "Darcy"

# Fix Heber Quinton for Cam Rayner, Cameron Sutcliffe, Alan Belcher, and James Robinson
Rows_to_Fix_BL = which(dat$Surname == "Quinton" & dat$Date > as.Date("1908-01-01", format = "%Y-%m-%d") & dat$Playing.for == "Brisbane Lions")
Rows_to_Fix_Freo = which(dat$Surname == "Quinton" & dat$Date > as.Date("1908-01-01", format = "%Y-%m-%d") & dat$Playing.for == "Fremantle")
Rows_to_Fix_Belcher = which(dat$Surname == "Quinton" & dat$Season == 1907 & dat$Round %in% c(1,2, 3,6,7,9,12) & dat$Playing.for == "Essendon")
Rows_to_Fix_Robinson = which(dat$Surname == "Quinton" & dat$Season == 1901 & dat$Round == 3 & dat$Playing.for == "Fitzroy")

dat$First.name[Rows_to_Fix_BL] = "Cam"
dat$Surname[Rows_to_Fix_BL] = "Rayner"
dat$ID[Rows_to_Fix_BL] = 12592

dat$First.name[Rows_to_Fix_Freo] = "Cameron"
dat$Surname[Rows_to_Fix_Freo] = "Sutcliffe"
dat$ID[Rows_to_Fix_Freo] = 12104

dat$First.name[Rows_to_Fix_Belcher] = "Alan"
dat$Surname[Rows_to_Fix_Belcher] = "Belcher"
dat$ID[Rows_to_Fix_Belcher] = 5187

dat$First.name[Rows_to_Fix_Robinson] = "James"
dat$Surname[Rows_to_Fix_Robinson] = "Robinson"
dat$ID[Rows_to_Fix_Robinson] = 4375

# Fix Les Hughsom for Mick Hughson in Rounds 10 and 12 of 1937 for Fitzroy
Rows_to_Fix_Hughson = which(dat$ID == 3098 & dat$Season == 1937 & dat$Round %in% c(10,12) & dat$Playing.for == "Fitzroy")

dat$First.name[Rows_to_Fix_Hughson] = "Les"
dat$ID[Rows_to_Fix_Hughson] = 3096

# Fix Bert Barling for Cecil Sandford in Round 4 of 1898 for Geelong
Rows_to_Fix_Sandford = which(dat$ID == 4410 & dat$Season == 1898 & dat$Round == 4 & dat$Playing.for == "Geelong")

dat$First.name[Rows_to_Fix_Sandford] = "Bert"
dat$Surname[Rows_to_Fix_Sandford] = "Barling"
dat$ID[Rows_to_Fix_Sandford] = 4382

# Fix George Hastings for Harry Wright in Round 2 of 1901 for Essendon
Rows_to_Fix_Wright = which(dat$ID == 4343 & dat$Season == 1901 & dat$Round == 2 & dat$Playing.for == "Essendon")

dat$First.name[Rows_to_Fix_Wright] = "George"
dat$Surname[Rows_to_Fix_Wright] = "Hastings"
dat$ID[Rows_to_Fix_Wright] = 4324

# Fix Clyde for Basil Smith in Round 18 of 1921 for Collingwood
Rows_to_Fix_Smith = which(dat$ID == 6805 & dat$Season == 1921 & dat$Round == 18 & dat$Playing.for == "Collingwood")

dat$First.name[Rows_to_Fix_Smith] = "Clyde"
dat$ID[Rows_to_Fix_Smith] = 6877

# Fix Bob for George King in Rounds 4 and 5 of 1916 for Fitzroy
Rows_to_Fix_King = which(dat$ID == 6183 & dat$Season == 1916 & dat$Round %in% c(4,5) & dat$Playing.for == "Fitzroy")

dat$First.name[Rows_to_Fix_King] = "Bob"
dat$ID[Rows_to_Fix_King] = 6405

# Fix OGorman, Sutherland and Warry misattributions in Rounds 4, 5, and 10 of 1900 for St Kilda
# No 1. Switch George Sutherland for Michael OGorman in Round 10
Rows_to_Fix_OSW_1 = which(dat$ID == 4295 & dat$Season == 1900 & dat$Round == 10 & dat$Playing.for == "St Kilda")

dat$First.name[Rows_to_Fix_OSW_1] = "George"
dat$Surname[Rows_to_Fix_OSW_1] = "Sutherland"
dat$ID[Rows_to_Fix_OSW_1] = 4735

# No 2. Switch Fred Warry for Michael OGorman in Round 5
Rows_to_Fix_OSW_2 = which(dat$ID == 4295 & dat$Season == 1900 & dat$Round == 5 & dat$Playing.for == "St Kilda")

dat$First.name[Rows_to_Fix_OSW_2] = "Fred"
dat$Surname[Rows_to_Fix_OSW_2] = "Warry"
dat$ID[Rows_to_Fix_OSW_2] = 4736

# No 3. Switch Michael OGorman for Fred Warry in Round 4
Rows_to_Fix_OSW_3 = which(dat$ID == 4736 & dat$Season == 1900 & dat$Round == 4 & dat$Playing.for == "St Kilda")

dat$First.name[Rows_to_Fix_OSW_3] = "Michael"
dat$Surname[Rows_to_Fix_OSW_3] = "OGorman"
dat$ID[Rows_to_Fix_OSW_3] = 4295

# Fix McCaskill, Don and Empey misattributions in Rounds 10 and 14 of 1925 for Richmond
# No 1. Switch Ralph Empey for Bob McCaskill in Round 14
Rows_to_Fix_MDE_1 = which(dat$ID == 3286 & dat$Season == 1925 & dat$Round == 14 & dat$Playing.for == "Richmond")

dat$First.name[Rows_to_Fix_MDE_1] = "Ralph"
dat$Surname[Rows_to_Fix_MDE_1] = "Empey"
dat$ID[Rows_to_Fix_MDE_1] = 6962

# No 2. Switch Donald Don for Ralph Empey in Round 10
Rows_to_Fix_MDE_2 = which(dat$ID == 6962 & dat$Season == 1925 & dat$Round == 10 & dat$Playing.for == "Richmond")

dat$First.name[Rows_to_Fix_MDE_2] = "Donald"
dat$Surname[Rows_to_Fix_MDE_2] = "Don"
dat$ID[Rows_to_Fix_MDE_2] = 2792

# Fix Clarrie Dall for Charlie McMillan in Round 17 of 1911 for Fitzroy
Rows_to_Fix_McMillan = which(dat$ID == 5991 & dat$Season == 1911 & dat$Round == 17 & dat$Playing.for == "Fitzroy")

dat$First.name[Rows_to_Fix_McMillan] = "Clarrie"
dat$Surname[Rows_to_Fix_McMillan] = "Dall"
dat$ID[Rows_to_Fix_McMillan] = 5983

# Fix Robert for George White in Round 5 of 1916 for Carlton
Rows_to_Fix_White_1 = which(dat$ID == 6416 & dat$Season == 1916 & dat$Round == 5 & dat$Playing.for == "Carlton")

dat$First.name[Rows_to_Fix_White_1] = "Robert"
dat$ID[Rows_to_Fix_White_1] = 6417

# Fix George for Robert White in Round 8 of 1916 for Carlton
Rows_to_Fix_White_2 = which(dat$ID == 6417 & dat$Season == 1916 & dat$Round == 8 & dat$Playing.for == "Carlton")

dat$First.name[Rows_to_Fix_White_2] = "George"
dat$ID[Rows_to_Fix_White_2] = 6416

# Remove extra George Shaw in Fitzroy R5 1912
dat = dat %>% filter(!(ID == 4580 & dat$Season == 1912 & dat$Round == 5))

# Remove extra Peter Stephens in Geelong R1 1907
dat = dat %>% filter(!(ID == 10665 & dat$Season == 1907 & dat$Round == 1))

# Remove extra Jim Stewart in St Kilda R3 1907
dat = dat %>% filter(!(ID == 5685 & dat$Season == 1907 & dat$Round == 3))

# Remove extra Albert Pannam in Collingwood R5 1907
dat = dat %>% filter(!(ID == 3500 & dat$Season == 1907 & dat$Round == 5))

# Remove extra Albert Pannam in Collingwood R12 1907
dat = dat %>% filter(!(ID == 3500 & dat$Season == 1907 & dat$Round == 12))

# Fix wrong date for 1928 SF Replay
dat$Date[dat$Season == 1928 & dat$Round == "SF" & dat$Attendance == 42175] = as.Date("1928-09-22", format = "%Y-%m-%d")

# Fix wrong date for 1946 SF Replay
dat$Date[dat$Season == 1946 & dat$Round == "SF" & dat$Attendance == 64400] = as.Date("1946-09-21", format = "%Y-%m-%d")

# Fix wrong date for 1948 GF Replay
dat$Date[dat$Season == 1948 & dat$Round == "GF" & dat$Attendance == 52226] = as.Date("1948-10-09", format = "%Y-%m-%d")

# Fix wrong date for 1962 PF Replay
dat$Date[dat$Season == 1962 & dat$Round == "PF" & dat$Attendance == 99203] = as.Date("1962-09-22", format = "%Y-%m-%d")

# Fix wrong date for 1972 SF Replay
dat$Date[dat$Season == 1972 & dat$Round == "SF" & dat$Attendance == 92670] = as.Date("1972-09-23", format = "%Y-%m-%d")

# Fix wrong date for 1977 GF Replay
dat$Date[dat$Season == 1977 & dat$Round == "GF" & dat$Attendance == 98491] = as.Date("1977-10-01", format = "%Y-%m-%d")

# Fix wrong date for 1990 QF Replay
dat$Date[dat$Season == 1990 & dat$Round == "GF" & dat$Attendance == 53520] = as.Date("1990-09-15", format = "%Y-%m-%d")

# Fix wrong date for 2010 QF Replay
dat$Date[dat$Season == 2010 & dat$Round == "GF" & dat$Attendance == 93853] = as.Date("2010-10-02", format = "%Y-%m-%d")

# Remove duplicated rows (because the Finals data is repeated multiple times)
dat = dat[!duplicated(dat[c("ID","First.name", "Surname", "Date", "Playing.for")]),]

afldata <- dat

# Write out
write_rds(afldata, here::here("data-raw", "afl_tables_playerstats", "afldata.rds"))
save(afldata, file = here::here("data-raw", "afl_tables_playerstats", "afldata.rda"))
