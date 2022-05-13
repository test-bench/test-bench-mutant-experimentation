module Mutant
  class Integration
    class Testbench
      class Reporter < ::Mutant::Reporter::CLI
        class Printer < ::Mutant::Reporter::CLI::Printer::EnvResult
          def run
            visit_collection(SubjectResult, failed_subject_results)
          end

          class SubjectResult < ::Mutant::Reporter::CLI::Printer::SubjectResult
            def run
              print "\e[31mSubject: \e[39m"
              status(subject.identification)

              tests.each do |test|
                puts " - #{test.identification}"
              end

              visit_collection(CoverageResult, uncovered_results)

              puts ""
            end
          end
        end

        def start(_env)
          puts
          puts "Running mutation tests"
          puts "- - -"
          puts
        end

        def report(env)
          Printer.call(output, env)

          if env.success?
            puts "\e[1;33mMutation tests passed\e[39;22m"
          else
            puts "\e[1;31mMutation tests failed\e[39;22m"
          end

          puts

          self
        end
      end
    end
  end
end
