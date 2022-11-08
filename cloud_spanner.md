```bash
gcloud spanner instances create first-instance \
    --config=regional-us-central1 \
    --description="First instance" \
    --nodes=1
    
gcloud spanner instances list

# Create a DB banking-db

# Create a table
CREATE TABLE Customer (
  CustomerId STRING(36) NOT NULL,
  Name STRING(MAX) NOT NULL,
  Location STRING(MAX) NOT NULL,
) PRIMARY KEY (CustomerId);

# Insert data
INSERT INTO
  Customer (CustomerId,
    Name,
    Location)
VALUES
  ('bdaaaa97-1b4b-4e58-b4ad-84030de92235',
    'Siva',
    'M'
    );


# insert 2nd
INSERT INTO
  Customer (CustomerId,
    Name,
    Location)
VALUES
  ('b2b4002d-7813-4551-b83b-366ef95f9273',
    'jeff',
    'b'
    );
    
 # Run a query
 SELECT * FROM Customer;
```
