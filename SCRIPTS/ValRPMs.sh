rpm -qa --queryformat "%{NAME}-%{VERSION}-%{RELEASE}.%{ARCH} = %{VENDOR} = %{installtime} (%{installtime:date}) \n"|grep tet >> output.tet
