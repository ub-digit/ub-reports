require_relative 'loan_renew'

module Yearly
  class Homeloan < LoanRenew
    QUERIES=["homeloan_issues", "homeloan_old_issues"]

    def run(year)
      run_queries(QUERIES, year)
    end
  end
end
