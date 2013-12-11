# Sert juste à désactiver Delayed::Jobs quand on veut tester
# 

# Commenter la ligne suivante pour activer Delayed::Jobs
 Delayed::Worker.delay_jobs = false