% for header in headerList:
<% header = header+'.h' %>
#import "${header}" 
% endfor

@protocol ${className} <NSObject> 
@end 

@interface ${className} : LuRequestModel <LuRequestDelegate>
% for property in properties:
<%
name = property['name']
type = property['type']
copyType = property['copyType']
%>
@property(nonatomic, ${copyType}) ${type} ${name};
% endfor


@end
