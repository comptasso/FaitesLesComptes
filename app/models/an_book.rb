class AnBook < Book


  def cumulated_at(date, dc)
    p = organism.find_period(date)
    val = p ? writings.joins(:compta_lines).period(p).where('date <= ?', date).sum(dc) : 0
    val.to_f # nécessaire car quand il n'y a aucune compa_lines, le retour est '0' et non 0 ce qui pose des
    # problèmes de calcul
  end
end
