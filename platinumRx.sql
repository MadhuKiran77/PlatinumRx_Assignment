CREATE TABLE users (
  user_id VARCHAR(50) PRIMARY KEY,
  name VARCHAR(100),
  phone_number VARCHAR(15),
  mail_id VARCHAR(100),
  billing_address TEXT
);
CREATE TABLE bookings (
  booking_id VARCHAR(50) PRIMARY KEY,
  booking_date DATETIME,
  room_no VARCHAR(50),
  user_id VARCHAR(50),
  FOREIGN KEY (user_id) REFERENCES users(user_id)
);
CREATE TABLE items (
  item_id VARCHAR(50) PRIMARY KEY,
  item_name VARCHAR(100),
  item_rate DECIMAL(10, 2)
);
CREATE TABLE booking_commercials (
  id VARCHAR(50) PRIMARY KEY,
  booking_id VARCHAR(50),
  bill_id VARCHAR(50),
  bill_date DATETIME,
  item_id VARCHAR(50),
  item_quantity DECIMAL(10, 2),
  FOREIGN KEY (booking_id) REFERENCES bookings(booking_id),
  FOREIGN KEY (item_id) REFERENCES items(item_id)
);
INSERT INTO
  users
VALUES
  (
    '21wrcxuy-67erfn',
    'John Doe',
    '97XXXXXXXX',
    'john.doe@example.com',
    'ABC City'
  );
INSERT INTO
  bookings
VALUES
  (
    'bk-09f3e-95hj',
    '2021-09-23 07:36:48',
    'rm-bhf9-aerjn',
    '21wrcxuy-67erfn'
  );
INSERT INTO
  items
VALUES
  ('itm-a9e8-q8fu', 'Tawa Paratha', 18),
  ('itm-a07vh-aer8', 'Mix Veg', 89);
INSERT INTO
  booking_commercials
VALUES
  (
    'q34r-3q4o8-q34u',
    'bk-09f3e-95hj',
    'bl-0a87y-q340',
    '2021-09-23 12:03:22',
    'itm-a9e8-q8fu',
    3
  ),
  (
    'q3o4-ahf32-o2u4',
    'bk-09f3e-95hj',
    'bl-0a87y-q340',
    '2021-09-23 12:03:22',
    'itm-a07vh-aer8',
    1
  );
A. Given the below schema for a hotel management system, write appropriate query to answer the following :-
1. For every user in the system, get the user_id and last booked room_no
SELECT
  b.user_id,
  b.room_no
FROM
  bookings b
  JOIN (
    SELECT
      user_id,
      MAX(booking_date) AS last_date
    FROM
      bookings
    GROUP BY
      user_id
  ) x ON b.user_id = x.user_id
  AND b.booking_date = x.last_date;
2. Get booking_id and total billing amount of every booking created in November, 2021
SELECT
  b.booking_id,
  SUM(bc.item_quantity * i.item_rate) AS total_amount
FROM
  bookings b
  JOIN booking_commercials bc ON b.booking_id = bc.booking_id
  JOIN items i ON bc.item_id = i.item_id
WHERE
  MONTH(b.booking_date) = 11
  AND YEAR(b.booking_date) = 2021
GROUP BY
  b.booking_id;
3. Get bill_id and bill amount of all the bills raised in October, 2021 having bill amount >1000
SELECT
  bc.bill_id,
  SUM(bc.item_quantity * i.item_rate) AS bill_amount
FROM
  booking_commercials bc
  JOIN items i ON bc.item_id = i.item_id
WHERE
  MONTH(bc.bill_date) = 10
  AND YEAR(bc.bill_date) = 2021
GROUP BY
  bc.bill_id
HAVING
  SUM(bc.item_quantity * i.item_rate) > 1000;

4. Determine the most ordered and least ordered item of each month of year 2021
  SELECT
    MONTH(bill_date) AS MONTH,
    item_id,
    SUM(item_quantity) AS total_qty
  FROM
    booking_commercials
  WHERE
    YEAR(bill_date) = 2021
  GROUP BY
    MONTH(bill_date),
    item_id
),
ranked AS (
  SELECT
    *,
    RANK() OVER(
      PARTITION BY MONTH
      ORDER BY
        total_qty DESC
    ) r1,
    RANK() OVER(
      PARTITION BY MONTH
      ORDER BY
        total_qty ASC
    ) r2
  FROM
    item_data
)
SELECT
  MONTH,
  item_id,
  total_qty,
  CASE
    WHEN r1 = 1 THEN 'Most Ordered'
    WHEN r2 = 1 THEN 'Least Ordered'
  END AS TYPE
FROM
  ranked
WHERE
  r1 = 1
  OR r2 = 1;
5. Find the customers with the second highest bill value of each month of year 2021
  SELECT
    b.user_id,
    MONTH(bc.bill_date) AS MONTH,
    SUM(bc.item_quantity * i.item_rate) AS total_bill
  FROM
    booking_commercials bc
    JOIN bookings b ON bc.booking_id = b.booking_id
    JOIN items i ON bc.item_id = i.item_id
  WHERE
    YEAR(bc.bill_date) = 2021
  GROUP BY
    b.user_id,
    MONTH(bc.bill_date)
),
ranked AS (
  SELECT
    *,
    DENSE_RANK() OVER(
      PARTITION BY MONTH
      ORDER BY
        total_bill DESC
    ) rnk
  FROM
    bill_data
)
SELECT
  *
FROM
  ranked
WHERE
  rnk = 2;
 B. For the below schema for a clinic management system, provide queries that solve for below questions :-
1. Find the revenue we got from each sales channel in a given year
SELECT sales_channel, SUM(amount) AS revenue
FROM clinic_sales
WHERE YEAR(datetime)=2021
GROUP BY sales_channel;
2. Find top 10 the most valuable customers for a given year
SELECT uid, SUM(amount) AS total_spent
FROM clinic_sales
WHERE YEAR(datetime)=2021
GROUP BY uid
ORDER BY total_spent DESC
LIMIT 10;
3. Find month wise revenue, expense, profit , status (profitable / not-profitable) for a given year
WITH rev AS (
    SELECT MONTH(datetime) m, SUM(amount) revenue
    FROM clinic_sales
    WHERE YEAR(datetime)=2021
    GROUP BY MONTH(datetime)
),
exp AS (
    SELECT MONTH(datetime) m, SUM(amount) expense
    FROM expenses
    WHERE YEAR(datetime)=2021
    GROUP BY MONTH(datetime)
)
SELECT r.m,
      r.revenue,
      e.expense,
      (r.revenue - e.expense) AS profit,
      CASE 
          WHEN (r.revenue - e.expense)>0 THEN 'Profitable'
          ELSE 'Not Profitable'
      END AS status
FROM rev r
JOIN exp e ON r.m = e.m;
4. For each city find the most profitable clinic for a given month
WITH profit_data AS (
    SELECT c.city, cs.cid,
          SUM(cs.amount) - COALESCE(SUM(e.amount),0) AS profit
    FROM clinic_sales cs
    JOIN clinics c ON cs.cid = c.cid
    LEFT JOIN expenses e ON cs.cid = e.cid
    GROUP BY c.city, cs.cid
),
ranked AS (
    SELECT *, RANK() OVER(PARTITION BY city ORDER BY profit DESC) rnk
    FROM profit_data
)
SELECT * FROM ranked WHERE rnk=1;
5. For each state find the second least profitable clinic for a given month
WITH profit_data AS (
    SELECT c.state, cs.cid,
          SUM(cs.amount) - COALESCE(SUM(e.amount),0) AS profit
    FROM clinic_sales cs
    JOIN clinics c ON cs.cid = c.cid
    LEFT JOIN expenses e ON cs.cid = e.cid
    GROUP BY c.state, cs.cid
),
ranked AS (
    SELECT *, DENSE_RANK() OVER(PARTITION BY state ORDER BY profit ASC) rnk
    FROM profit_data
)
SELECT * FROM ranked WHERE rnk=2;