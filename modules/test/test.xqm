xquery version "3.0";

module namespace test="http://sade/test";

declare function test:main ($node as node(), $model as map(*)) {
 
    <p>{
        for $prop in $model("config")//properties/property
            return (concat(xs:string($prop/@key),": ",xs:string($prop/text())),<br/>)
       }</p>
 
};
