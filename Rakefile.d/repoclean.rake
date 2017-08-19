task :repoclean do
  system "rm -fr pickle-email-* .bundle/ .yardoc/ cucumber_test_app/ doc/ tmp"
end
