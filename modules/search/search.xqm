module namespace search = "http://sade/search" ;

declare function search:process-template($template-node as node(), $config as node()) as item()* {
    let $value:=  request:get-parameter("query", "")
    let $data_coll := $config//data/@path
    let $result := if ($value ne "") then collection($data_coll)//*[contains(.,$value)] else ""
    return
      <div><h2>search</h2>
      <form >
        query <input type="text" name="query" value="{$value}"/><input type="submit" value="submit"/>        
        </form>
        result: {$result}
      </div>      
};

declare function search:header($config as node()) as item()* {
    ()
};
