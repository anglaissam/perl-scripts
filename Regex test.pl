#Help Test Regex

#Insert test document here
$str = <<END;
<HTML>
<BODY>
<P>ah ring</P>
<P>a ring</P>
<P>This is the ring</P>
</HTML>
END

$regex = qr/(?<=a|the|one)\x20ring/; #Test regex

for (split /^/, $str) {
    #Insert Regex below, and create a test html file
    if ($_ =~ m/($regex)/i) {
        print "Found \"$1\": $_\n";
    }
    else {
        print "Not Found: $_\n";
    }
}
system("pause");
exit(0);