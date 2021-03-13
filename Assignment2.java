/* 
 * This code is provided solely for the personal and private use of students 
 * taking the CSC343H course at the University of Toronto. Copying for purposes 
 * other than this use is expressly prohibited. All forms of distribution of 
 * this code, including but not limited to public repositories on GitHub, 
 * GitLab, Bitbucket, or any other online platform, whether as given or with 
 * any changes, are expressly prohibited. 
*/ 

import java.sql.*;
import java.util.Date;
import java.util.Arrays;
import java.util.List;
import java.lang.Math;
import java.util.ArrayList;

public class Assignment2 {
   /////////
   // DO NOT MODIFY THE VARIABLE NAMES BELOW.
   
   // A connection to the database
   Connection connection;

   // Can use if you wish: seat letters
   List<String> seatLetters = Arrays.asList("A", "B", "C", "D", "E", "F");

   Assignment2() throws SQLException {
      try {
         Class.forName("org.postgresql.Driver");
      } catch (ClassNotFoundException e) {
         e.printStackTrace();
      }
   }

  /**
   * Connects and sets the search path.
   *
   * Establishes a connection to be used for this session, assigning it to
   * the instance variable 'connection'.  In addition, sets the search
   * path to 'air_travel, public'.
   *
   * @param  url       the url for the database
   * @param  username  the username to connect to the database
   * @param  password  the password to connect to the database
   * @return           true if connecting is successful, false otherwise
   */
   public boolean connectDB(String URL, String username, String password) {
      try{
         Class.forName("org.postgresql.Driver");
         connection = DriverManager.getConnection(URL, username, password);
         Statement state = connection.createStatement();
         String query = "SET search_path TO air_travel, public;";
         state.executeUpdate(query);
      } catch (Exception e){
         e.printStackTrace();         
         return false;
      }
      return true;
   }

  /**
   * Closes the database connection.
   *
   * @return true if the closing was successful, false otherwise
   */
   public boolean disconnectDB() {
      // Implement this method!
      try{
         connection.close();
      } catch(Exception e){
         e.printStackTrace();
         return false;
      }
      return true;
   }
   
   /* ======================= Airline-related methods ======================= */

   /**
    * Attempts to book a flight for a passenger in a particular seat class. 
    * Does so by inserting a row into the Booking table.
    *
    * Read handout for information on how seats are booked.
    * Returns false if seat can't be booked, or if passenger or flight cannot be found.
    *
    * 
    * @param  passID     id of the passenger
    * @param  flightID   id of the flight
    * @param  seatClass  the class of the seat (economy, business, or first) 
    * @return            true if the booking was successful, false otherwise. 
    */
   public boolean bookSeat(int passID, int flightID, String seatClass) {
      // Implement this method!
      int ret = 0;
      try{
         String query = "SELECT * FROM plane,booking,flight,price WHERE booking.flight_id = flight.id AND flight.plane = plane.tail_number AND price.flight_id = flight.id AND flight.airline = plane.airline AND flight.id = " + flightID + ";";
         Statement stat = connection.createStatement();
         ResultSet ans = stat.executeQuery(query);
         int capacity_first = 0, capacity_eco = 0, capacity_bus = 0, ct_f = 0, ct_b = 0, ct_e = 0, price_e = 0, price_f = 0, price_b = 0;
         int row_e = 0, row_f = 0, row_b = 0, id= 0;
         String seat_e = "", seat_f = "", seat_b = "";
         while(ans.next()){
            capacity_first = ans.getInt("capacity_first");
            capacity_eco = ans.getInt("capacity_economy");
            capacity_bus = ans.getInt("capacity_business");
            price_e = ans.getInt("economy");
            price_f = ans.getInt("first");
            price_b = ans.getInt("business");
            if(ans.getString("seat_class").equals("first")){
               ct_f += 1;
               if(ans.getInt("row")>row_f){
                  row_f = ans.getInt("row");
                  seat_f = ans.getString("letter");
               }
            }           
            if(ans.getString("seat_class").equals("business")){
               ct_b += 1;
               if(ans.getInt("row")>row_b){
                  row_b = ans.getInt("row");
                  seat_b = ans.getString("letter");
               }
            }           
            if(ans.getString("seat_class").equals("economy")){
               ct_e += 1;
               if(ans.getInt("row") > 0 && ans.getInt("row")>row_e){
                  row_e = ans.getInt("row");
                  seat_e = ans.getString("letter");
               }
            }           
         }
         query = "SELECT * FROM booking";
         ans = stat.executeQuery(query);
         while(ans.next()){
            id = ans.getInt("id");
         }
         id = id + 1;
         if(row_f == 0){
            row_f = 1;
         }
         if(row_b == 0){
            row_b = (int)(Math.ceil(capacity_first / 6)) + 1;
         }
         if(row_e == 0){
            row_e = (int)(Math.ceil(capacity_first / 6)) + (int)(Math.ceil(capacity_bus / 6)) + 1;
         }
         if(seatClass.equals("first")){
            if(ct_f < capacity_first * 6){
               ret = 1;
               if(seat_f.equals("F")){
                  row_f = row_f + 1;
                  query = "INSERT INTO booking VALUES (" + id + ", " + passID + ", " + flightID + ", '" + getCurrentTimeStamp() + "', " + price_f + ", " + "'first', " + row_f + ", 'A');";
                  stat.executeUpdate(query);
               }
               else{
                  int pos = seatLetters.indexOf(seat_f) + 1;
                  query = "INSERT INTO booking VALUES (" + id + ", " + passID + ", " + flightID + ", '" + getCurrentTimeStamp() + "', " + price_f + ", " + "'first', " + row_f + ", '" + seatLetters.get(pos)+ "');";
                  stat.executeUpdate(query);
               }
            }
         }
         else if(seatClass.equals("business")){
            if(ct_b < capacity_bus * 6){
               ret = 1;
               if(seat_b.equals("F")){
                  row_b = row_b + 1;
                  query = "INSERT INTO booking VALUES (" + id + ", " + passID + ", " + flightID + ", '" + getCurrentTimeStamp() + "', " + price_b + ", " + "'business', " + row_b + ", 'A');";
                  stat.executeUpdate(query);
               }
               else{
                  int pos = seatLetters.indexOf(seat_b) + 1;
                  query = "INSERT INTO booking VALUES (" + id + ", " + passID + ", " + flightID + ", '" + getCurrentTimeStamp() + "', " + price_b + ", " + "'business', " + row_b + ", '" + seatLetters.get(pos)+ "');";
                  stat.executeUpdate(query);
               }
            }
         }
         else {
            if(ct_e < capacity_eco * 6){
               ret = 1;
               if(seat_e.equals("F")){
                  row_e = row_e + 1;
                  query = "INSERT INTO booking VALUES (" + id + ", " + passID + ", " + flightID + ", '" + getCurrentTimeStamp() + "', " + price_e + ", " + "'economy', " + row_e + ", 'A');";
                  stat.executeUpdate(query);
                  System.out.println("Here");
               }
               else{
                  int pos = seatLetters.indexOf(seat_e) + 1;
                  query = "INSERT INTO booking VALUES (" + id + ", " + passID + ", " + flightID + ", '" + getCurrentTimeStamp() + "', " + price_e + ", " + "'economy', " + row_e + ", '" + seatLetters.get(pos)+ "');";
                  stat.executeUpdate(query);
               }
            }
            else if(ct_e >= capacity_eco * 6 && ct_e < (capacity_eco*6 + 10)){
               query = "INSERT INTO booking VALUES (" + id + ", " + passID + ", " + flightID + ", '" + getCurrentTimeStamp() + "', " + price_e + ", " + "'economy',,);";
               stat.executeUpdate(query);
            }
         }
      } catch(Exception e){
         e.printStackTrace();
         return false;
      }
      if(ret == 1){
         return true;
      }
      return false;
   }

   /**
    * Attempts to upgrade overbooked economy passengers to business class
    * or first class (in that order until each seat class is filled).
    * Does so by altering the database records for the bookings such that the
    * seat and seat_class are updated if an upgrade can be processed.
    *
    * Upgrades should happen in order of earliest booking timestamp first.
    *
    * If economy passengers are left over without a seat (i.e. more than 10 overbooked passengers or not enough higher class seats), 
    * remove their bookings from the database.
    * 
    * @param  flightID  The flight to upgrade passengers in.
    * @return           the number of passengers upgraded, or -1 if an error occured.
    */
   public int upgrade(int flightID) {
      try{
         String query = "SELECT * FROM plane,booking,flight,price WHERE booking.flight_id = flight.id AND flight.plane = plane.tail_number AND price.flight_id = flight.id AND flight.airline = plane.airline AND flight.id = " + flightID + ";";
         Statement stat = connection.createStatement();
         ResultSet ans = stat.executeQuery(query);
         int capacity_first = 0, capacity_eco = 0, capacity_bus = 0, ct_f = 0, ct_b = 0, ct_e = 0, price_e = 0, price_f = 0, price_b = 0;
         int row_e = 0, row_f = 0, row_b = 0, ct = 0;
         String seat_e = "", seat_f = "", seat_b = "";
         while(ans.next()){
            capacity_first = ans.getInt("capacity_first");
            capacity_eco = ans.getInt("capacity_economy");
            capacity_bus = ans.getInt("capacity_business");
            price_e = ans.getInt("economy");
            price_f = ans.getInt("first");
            price_b = ans.getInt("business");
            if(ans.getString("seat_class").equals("first")){
               ct_f += 1;
               if(ans.getInt("row")>row_f){
                  row_f = ans.getInt("row");
                  seat_f = ans.getString("letter");
               }
            }           
            if(ans.getString("seat_class").equals("business")){
               ct_b += 1;
               if(ans.getInt("row")>row_b){
                  row_b = ans.getInt("row");
                  seat_b = ans.getString("letter");
               }
            }           
            if(ans.getString("seat_class").equals("economy")){
               ct_e += 1;
               if(ans.getInt("row") > 0 && ans.getInt("row")>row_e){
                  row_e = ans.getInt("row");
                  seat_e = ans.getString("letter");
               }
            }           
         }
         int num_avail = (capacity_bus * 6) - ct_b + (capacity_first * 6) - ct_f;
         int ct_ret = 0;
        
         if(num_avail <= 0){
            return 0;
         }
         System.out.println("Hi");
         query = "SELECT * FROM booking WHERE row IS NULL AND flight_id = " + flightID + " ORDER BY datetime;";
         ans = stat.executeQuery(query);
         List<String> queries = new ArrayList<String>();         
         System.out.println(queries);
         while(ans.next()){
            int id = ans.getInt("id");
            if(num_avail > 0){
               ct_ret += 1;
               if(ct_b < capacity_bus * 6){
                  if(seat_b.equals("F")){
                     row_b = row_b + 1;
                     queries.add("UPDATE booking SET seat_class = 'business', row = "+ row_b + ", letter = 'A' WHERE id = " + id + ";");
                  }
                  else{
                     int pos = seatLetters.indexOf(seat_b) + 1;
                     queries.add("UPDATE booking SET seat_class = 'business', row = "+ row_b + ", letter = '" + seatLetters.get(pos) + "' WHERE id = " + id + ";");
                  }
               }
               else{
                  if(seat_f.equals("F")){
                     row_f = row_f + 1;
                     queries.add("UPDATE booking SET seat_class = 'first', row = "+ row_f + ", letter = 'A' WHERE id = " + id + ";");
                  }
                  else{
                     int pos = seatLetters.indexOf(seat_f) + 1;
                     queries.add("UPDATE booking SET seat_class = 'first', row = "+ row_f + ", letter = '" + seatLetters.get(pos) + "' WHERE id = " + id + ";");
                  }
               }
            }
            else{
               queries.add("DELETE FROM booking WHERE id = " + id + ";");
            }
            num_avail -= 1;
         }
         for(String q: queries){
            stat.executeUpdate(q);
         }
         query = "SELECT * FROM booking WHERE row IS NULL AND flight_id = " + flightID + " ORDER BY datetime;";

         ans = stat.executeQuery(query);
         while(ans.next()){
            System.out.println("hi");
         }
         return ct_ret;
      } catch(Exception e){
         e.printStackTrace();
         return -1;
      }
   }


   /* ----------------------- Helper functions below  ------------------------- */

    // A helpful function for adding a timestamp to new bookings.
    // Example of setting a timestamp in a PreparedStatement:
    // ps.setTimestamp(1, getCurrentTimeStamp());

    /**
    * Returns a SQL Timestamp object of the current time.
    * 
    * @return           Timestamp of current time.
    */
   private java.sql.Timestamp getCurrentTimeStamp() {
      java.util.Date now = new java.util.Date();
      return new java.sql.Timestamp(now.getTime());
   }

   // Add more helper functions below if desired.


  
  /* ----------------------- Main method below  ------------------------- */

   public static void main(String[] args) {
      // You can put testing code in here. It will not affect our autotester.
      // System.out.println("Running the code!");
      String url = "jdbc:postgresql://localhost:5432/csc343h-gurumur2";
      String username =  "gurumur2";
      String password = "";
      try{
         Assignment2 a = new Assignment2();
         System.out.println(a.connectDB(url, username, password));
         // System.out.println("connect done!");
         a.bookSeat(6,5,"first");
         System.out.println(a.upgrade(5));
         // System.out.println("boook done!");
         a.disconnectDB();
      }
      catch(Exception e){}
   }
}
