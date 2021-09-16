require_relative 'loan_renew'

module Yearly
  class ILLOutFor < LoanRenew
    QUERIES=["illout_for_issues", "illout_for_old_issues"]

    def run(year)
      run_queries(QUERIES, year)
    end
  end
end