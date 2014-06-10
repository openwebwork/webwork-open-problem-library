######################################################################
##
##  Functions for creating tables that conform to accessibility standards
##  This library is an evolution from unionTables.pl, but the evolution  
##    became too complicated to simply modify unionTables.pl.
##
##    DataTable()             Creates a table with data. Among other things, 
##                                   in HTML the cells can have the header tag. 
##                                   Should not be used for layout, such as displaying 
##                                   an array of graphs
##
##    LayoutTable()           Creates a table using div boxes for layout
##

sub _pccTables_init {}; # don't reload this file

=head2 pccTables.pl

 ######################################################################
 #
 #  Command for tables displaying data.
 #
 #  Usage:  DataTable([[a,b,c,...],[d,e,f,...],[g,h,i,...],...], options);
 #
 #  [[a,b,c,...],[d,e,f,...],[g,h,i,...],...] is the table content row by row
 #  Each cell entry (like "a") can be replaced with a hash reference for more detailed 
 #    customization of that cell: 
 #      {data => a, 
 #      header => type,                           #could be 'TH' (table header), 'CH' (col header), 'RH' (row header), or none of the above
 #      cellcss => extra css for the cell,  #string with cell-specific CSS styling
 #      texpre => tex code,                     # for cell by cell alteration of the tex version of the table
 #      texpost => tex code}                   # in case something opened in texpre needs to be closed
 #  
 #   Additionally, a rowcss key can be used anywhere in the row and the last instance in that row will be applied to the row
 #      [[{rowcss => extra css for the row, data=>a},b,c,...],[d,e,f,...],[g,h,i,...],...]
 #
 #  Options for the whole table are:
 #
 #    center => 0 or 1         center table
 #    texalignment => string     something like 'rccl'; if left blank, all c's for the table
 #    tablecss => string           css styling commands for the table element
 #    datacss => string           css styling commands for all the td elements
 #    headercss => string           css styling commands for the th elements
 #    allcellcss => string         css styling commands for all the cells
 #    caption => string            a caption for the table
 #    captioncss => string           css styling commands for the caption element
 #
 #        css styling commands offer a huge variety. 
 #        Basic elements are of the form "A:B;" like "border:1pt;" and "width:80%;"
 #          DON'T FORGET THE SEMICOLONS
 #        Also, they can be of the form "A:B C;" like "border:1pt dashed;"
 #        Multiple commands can be used with the form "A1:B;A2:C;" like "border:1pt; margin:5pt;"
 #        Some properties with example values and which elements they can affect:
 #            border:2px solid blue;    table, caption, th, td
 #            border-collapse:collapse;    table
 #            width:50%;    table, caption, th, td
 #            height:20ex;    table, caption, tr, th, td
 #            text-align:center;    table, caption, tr, th, td
 #            vertical-align:top;    table, caption, tr, th, td
 #            padding:12pt;    table, caption, th, td
 #            margin:20px;   table, caption
 #            border-spacing:12pt;    table
 #            caption-side:bottom;    table, caption
 #            color:blue;    table, caption, tr, th, td
 #            background-color:yellow;    table, caption, tr, th, td
 #        The properties border, padding, and margin
 #            can be specified in more detail using -left, -bottom, -right, -top as in "border-bottom:5px"
 #
 #  Example: DataTable([[{data=>1, header => 'CH', cellcss => 'color:blue;'},2,3],
 #                                   [4,5,{rowcss => 'background-color:yellow;', data => 6}]], tablecss => "border:1pt");\}

=cut

sub DataTable {
  my $dataref = shift;

  # this array will store the number of cells in each row
  my @numcols = ();

  # if any cells were simply entered as their data value, convert to a hash
  for my $i (0..$#{$dataref})
    {$numcols[$i] = $#{$dataref->[$i]};
    for my $j (0..$numcols[$i])
      {$dataref->[$i][$j] = {data => $dataref->[$i][$j]} unless (ref($dataref->[$i][$j]) eq "HASH" );
      };
    };

  # total number of columns
  my $numcol = max(@numcols)+1;

  # define options
  my %options = (
    center => 1, caption => '', tablecss => '', captioncss => '', datacss => '',
    headercss => '', allcellcss => '', texalignment => '', 
    @_
  );
  my $caption = $options{caption};
  my ($tablecss, $captioncss, $datacss, $headercss, $allcellcss, $texalignment) = 
    ($options{tablecss},$options{captioncss},$options{datacss},$options{headercss},$options{allcellcss},$options{texalignment},);
  my $center = $options{center};
    if ($center !=0) {$tablecss .= 'text-align:center;margin:0 auto;'};

  # for each row, store rowcss
  my @rowcss = ();
  for my $i (0..$#{$dataref})
    {$rowcss[$i] = '';
    for my $j (0..$numcols[$i])
      {$rowcss[$i] = ${$dataref->[$i][$j]}{rowcss} if (defined ${$dataref->[$i][$j]}{rowcss} );
      };
    };

  # build html string for the table
  my $table =
    '<TABLE style = "'.$tablecss.'">';
  if ($caption ne '') {$table .= '<CAPTION style = "'.$captioncss.'">'.$caption.'</CAPTION>';}
  for my $i (0..$#{$dataref})
    {$table .= '<TR style = "'.$rowcss[$i].'">';
    for my $j (0..$numcols[$i])
      {if (uc(${$dataref->[$i][$j]}{header}) eq 'TH')
        {$table .= '<TH style = "'.$allcellcss.$headercss.${$dataref->[$i][$j]}{cellcss}.'">'.${$dataref->[$i][$j]}{data}.'</TH>';}
        elsif (uc(${$dataref->[$i][$j]}{header}) eq 'CH') 
        {$table .= '<TH scope = "col" style = "'.$allcellcss.$headercss.${$dataref->[$i][$j]}{cellcss}.'">'.${$dataref->[$i][$j]}{data}.'</TH>';}
        elsif (uc(${$dataref->[$i][$j]}{header}) eq 'RH') 
        {$table .= '<TH scope = "row" style = "'.$allcellcss.$headercss.${$dataref->[$i][$j]}{cellcss}.'">'.${$dataref->[$i][$j]}{data}.'</TH>';}
        else {$table .= '<TD style = "'.$allcellcss.$datacss.${$dataref->[$i][$j]}{cellcss}.'">'.${$dataref->[$i][$j]}{data}.'</TD>';}
      }
    $table .= "</TR>";
    };
    $table .= "</TABLE>";

    
    $texalignment = join('', ('c') x $numcol) if ($texalignment eq '');

    $textable = ($center == 1) ? '\begin{center}' : '\begin{flushleft}';
    $textable .= '\begin{tabular}{'.$texalignment.'}';
    if ($caption ne '') {$textable .= '\multicolumn{'.$numcol.'}{c}{\makebox[0pt]{'.$caption.'}}\\\\';};
    for my $i (0..$#{$dataref})
      {for my $j (0..$numcols[$i])
        {$textable .= ${$dataref->[$i][$j]}{texpre}.' '.${$dataref->[$i][$j]}{data}.' '.${$dataref->[$i][$j]}{texpost};
        $textable .= '&' unless ($j == $numcols[$i]);
        };
      $textable .= '\\\\' unless ($i == $#{$dataref});
      };
    $textable .= '\end{tabular}';
    if ($center ==1) {$textable .= '\end{center}'} else {$textable .= '\end{flushleft}'};

  MODES(
    TeX => $textable,
    HTML => $table,
  );
}

=pod

 #
 #  Command for table to control layout
 #
 #  Usage:  LayoutTable(...)  
 #    See usage for DataTable. The main difference is that the HTML output
 #    will use div boxes instead of HTML tables. Header tags and caption tags 
 #    no longer make sense, nor do css styling for headers, captions, and data cells.



=cut

sub LayoutTable {
  my $dataref = shift;

  # this array will store the number of cells in each row
  my @numcols = ();

  # if any cells were simply entered as their data value, convert to a hash
  for my $i (0..$#{$dataref})
    {$numcols[$i] = $#{$dataref->[$i]};
    for my $j (0..$numcols[$i])
      {$dataref->[$i][$j] = {data => $dataref->[$i][$j]} unless (ref($dataref->[$i][$j]) eq "HASH" );
      };
    };

  # total number of columns
  my $numcol = max(@numcols)+1;

  # define options
  my %options = (
    center => 1, tablecss => '',
    texalignment => '', allcellcss => '',
    @_
  );
  my ($tablecss, $texalignment, $allcellcss) = 
    ($options{tablecss},$options{texalignment},$options{allcellcss},);
  my $center = $options{center};
    if ($center !=0) {$tablecss .= 'text-align:center;margin:0 auto;'};

  # for each row, store rowcss
  my @rowcss = ();
  for my $i (0..$#{$dataref})
    {$rowcss[$i] = '';
    for my $j (0..$numcols[$i])
      {$rowcss[$i] = ${$dataref->[$i][$j]}{rowcss} if (defined ${$dataref->[$i][$j]}{rowcss} );
      };
    };

  # build html string for the table
  my $table =
    '<DIV style = "display:table;'.$tablecss.'">';
  for my $i (0..$#{$dataref})
    {$table .= '<DIV style = "display:table-row;'.$rowcss[$i].'">';
    for my $j (0..$numcols[$i])
      {$table .= '<DIV style = "display:table-cell;'.$allcellcss.${$dataref->[$i][$j]}{cellcss}.'">'.${$dataref->[$i][$j]}{data}.'</DIV>';}
    $table .= "</DIV>";
    };
    $table .= "</DIV>";

    
    $texalignment = join('', ('c') x $numcol) if ($texalignment eq '');

    $textable = ($center == 1) ? '\begin{center}' : '\begin{flushleft}';
    $textable .= '\begin{tabular}{'.$texalignment.'}';
    if ($caption ne '') {$textable .= '\multicolumn{'.$numcol.'}{c}{\makebox[0pt]{'.$caption.'}}\\\\';};
    for my $i (0..$#{$dataref})
      {for my $j (0..$numcols[$i])
        {$textable .= ${$dataref->[$i][$j]}{texpre}.' '.${$dataref->[$i][$j]}{data}.' '.${$dataref->[$i][$j]}{texpost};
        $textable .= '&' unless ($j == $numcols[$i]);
        };
      $textable .= '\\\\' unless ($i == $#{$dataref});
      };
    $textable .= '\end{tabular}';
    if ($center ==1) {$textable .= '\end{center}'} else {$textable .= '\end{flushleft}'};

  MODES(
    TeX => $textable,
    HTML => $table,
  );
}

1;
