require_relative 'loan_renew'

module Yearly
  class ILLOutSv < LoanRenew
    QUERIES=["illout_sv_issues", "illout_sv_old_issues"]

    def run(year)
      run_queries(QUERIES, year)
    end
  end
end