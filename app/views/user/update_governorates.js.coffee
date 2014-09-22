$("#governorates_select").empty().append("<%= escape_javascript(render(:partial => @governorates)) %>")
$("#regions_select").empty().append("<%= escape_javascript(render(:partial => @regions)) %>")