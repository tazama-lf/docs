# Strings vs Predicate for frms-coe-lib DAL

- [Strings vs Predicate for frms-coe-lib DAL](#strings-vs-predicate-for-frms-coe-lib-dal)
- [Introduction](#introduction)
  - [Function Signature](#function-signature)
  - [String](#string)
    - [String Drawbacks](#string-drawbacks)
  - [Predicate](#predicate)
    - [Predicate Drawbacks](#predicate-drawbacks)
  - [Conclusion](#conclusion)

# Introduction

`frms-coe-lib` provides generic queries for the databases. These queries have an identical function signature: As an example, we’ll look at `queryPseudonymDB`

## Function Signature

`queryPseudonymDB(collection: string, filters: string, limit?: number)`

collection → a `string` value of the collection you want your query to target.

filters → a `string` of chained ‘key {logical operator} value’ to use as a search predicate in your query.

limit → an optional parameter of `number` that denotes, well, the maximum number of records you would like to return.

Example usage could be as follows:

```aql
// Assuming we have a database client initialised to a variable `dbManager`
const filter = `doc.field1 == 'foo' AND doc.field2 == 'bar'`;
const result = await dbManager.queryPseudonymDB('collection', filter); 
```

Breaking down the first part, our `filter`:

There are 3 parts we need to pay attention to.

1. Get the field we want to specify a filter on: `doc.field1`
2. A logical operator to apply on the targeted field: `==`
3. The target value we would like to filter by: `'foo'`

> Find all documents where field1 has the value of 'foo' …

We can chain filters with logical operators (`AND/OR/NOT`) as we did with `field2`

> … and field2 has the value of ‘bar’

## String

Our current implementation, dissecting the code, our implementation is as follows:

```aql
queryPseudonymDB = async (collection: string, filter: string, limit?: number) => {
    const aqlFilter = aql`${filter}`;
    const aqlLimit = limit ? aql`LIMIT ${limit}` : undefined;
    const query: AqlQuery = aql`
      FOR doc IN ${db}
      FILTER ${aqlFilter}
      ${aqlLimit}
      RETURN doc
    `;
    // omitted
  };

```

We directly slot the string into our query. When this function runs, there’s not much processing it does besides constructing the `AqlQuery` after evaluating the limit using a [ternary operator](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Operators/Conditional_operator). We then send the query to our database.

### String Drawbacks

Well, you may notice immediately that your filter (downstream) can be quite a bit verbose depending on the number of filters you want to apply. Image a case where we want to have 5 filters. The string just gets longer and longer.  
Also, there’s nothing stopping you from duplicating a filter on the same key with different values.

```aql
// Assuming we have a database client initialised to a variable `dbManager`
const filter = `doc.field1 == 'foo' AND doc.field1 == 'bar'`;
const result = await dbManager.queryPseudonymDB('collection', filter);
```

That is perfectly valid code. But if you look deeper, how can `field1` be ‘foo’ and ‘bar’ at the same time? How would the database evaluate such a query? Don’t know. You could assume the second filter is used but it could very well be different for each database’s implementation. Suppose you then want to get the filter you applied on `field1`, you need to find where you created the filter and lookup the value you provided, if you want to do it programmatically, you have to do a string search and then strip everything else or something else that will probably need you to write a few tests for it so you can sleep with a peace of mind. It can get more difficult if you perhaps duplicated a field.

The string is not really database agnostic as well. It assumes that’s how the database does its filtering per query. What would happen if you were using an SQL database?

What other options do we have?

## Predicate

We could have some sort of data structure, not a string specifically, but something we can use to build a string. Something catered to deal with key-value pairs (for filtering) - a (hash)map/table comes to mind.

The key stores the field we want to target,

The value stores the value we are filtering by.

```aql
const filters = new Map()
filters.set('field1', 'foo')
filters.set('field2', 'bar')
```

Notice how we also got rid of the `doc.` prefix? We could leave that to the internal implementation of the function. (This certainly is possible as well with the `string` approach.)

This would require us to change the function signature to something like:

```aql
// Where T is a type that can be converted to a string
queryPseudonymDB(collection: string, filters: Map<String, T>, limit?: number)
```

So we can use strings and numbers as the values we want to search for but anything else that can be converted to a string. For simplicity’s sake, lets say something that can call `.toString()` so you could create your own data structure and have a `toString()` implementation and practically, you should be able to just put it in the Map, and you'll be on your way. Oh and also we get rid of the "sending a filter on the same field more than once":

```aql
filters.set('field1', 5);
filters.set('field1', 'foo'); // overwrites the previous value of the same key
```

If you need to find out what filter you provided on `field1`, you can just get the value from the map.  
This approach allows you to internally interpret the key-values however you would like. Using an SQL database? No problem, simply change the implementation internally. Nothing else needs to change downstream.

Seems pretty great, right? Well, it may not be as straight forward.

### Predicate Drawbacks

Let’s consider the new implementation of `queryPseudonymDB`:

```aql
queryPseudonymDB = async <T extends ToString>(collection: string, filter: Map<T, T>, limit?: number) => {
    // omitted
    let filterStr = '';
    for (const [key, value] of filter) {
      filterStr = `${filterStr} FILTER doc.${key} == doc.${value.toString()}`;
    }
    const aqlFilter = aql`${filterStr}`;
    const aqlLimit = limit ? aql`LIMIT ${limit}` : undefined;
    const query: AqlQuery = aql`
      FOR doc IN ${db}
      ${aqlFilter}
      ${aqlLimit}
      RETURN doc
    `;
   // more stuff here
  };
```

Right off the bat, we’re going to have to iterate over the `filter`. And depending on the `toString()` implementation (since we're calling that per iteration), it can be fairly costly.  
  
Also remember the 3 parts in a filter we needed to keep in mind? We have two here and the logical operator is not accounted for. What if I want a `!=` instead of `==`? We then need to have some sort of algorithm for accounting for that.

```aql
interface FilterVal {
  logicalOperator: LogicalOperator,
  value: /* some type that implements toString() */
}
```

And then you’d need another data structure to represent all the `LogicalOperator` types. Then maybe you could create your `Map<String, FilterVal>()` and then per iteration, you have to check the logical operators along with calling `toString()`. What if you need to nest predicates? Your value now then needs to be not just a string, but some sort of collection as well, that’s more allocations and potentially (probably) more loops. Depending on your priorities, this can be a deal breaker.  

## Conclusion

If you’re chasing performance, the current implementation (string based filtering) is faster, though it requires a bit more care from the developer.  
  
Interested in building predicates? This [predicate-builder-service](https://github.com/frmscoe/predicate-builder-service) may be of interest.
