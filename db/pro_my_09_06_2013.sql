-- phpMyAdmin SQL Dump
-- version 3.5.2.2
-- http://www.phpmyadmin.net
--
-- Host: 127.0.0.1
-- Generation Time: Jun 08, 2013 at 08:30 PM
-- Server version: 5.5.27
-- PHP Version: 5.4.7

SET SQL_MODE="NO_AUTO_VALUE_ON_ZERO";
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;

--
-- Database: `pro_my`
--

DELIMITER $$
--
-- Procedures
--
CREATE DEFINER=`root`@`localhost` PROCEDURE `SPapmaddemail`(
IN iemailfrom varchar(255),
IN iemailto varchar(255),
IN iemailsubject text,
IN iemailbody blob,
IN ireferenceid BIGINT(18)

)
BEGIN





Declare tstatusid int(11);
Declare tappid int(11) default 0;
Declare toutput varchar(255);

SELECT statusid into tstatusid FROM apmmasterrecordsstate  where recordstate='Active';
-- select appid into tappid from apmmasterapps where appname = iappname and statusid = tstatusid;

-- if tappid <> 0 then

  if ireferenceid = '' or ireferenceid is Null then

  insert into apmmailqueue(emailfrom, emailto, emailsubject, body,createddatetime, statusid,mailstatus)
  values
  (iemailfrom, iemailto, iemailsubject, iemailbody, now(), tstatusid,1);

  else

  insert into apmmailqueue(emailfrom, emailto, emailsubject, body, referenceid, createddatetime, statusid,mailstatus)
  values
  (iemailfrom, iemailto, iemailsubject, iemailbody, ireferenceid,  now(), tstatusid,1);


  end if;
  set toutput = '1#successfully added';
  select toutput;

-- else

  -- set toutput = '0#app doesnot exists';
  -- select toutput;

-- end if;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `SPapmchangepassword`(
IN iuserid int(11),
IN ioldpassword varchar(255),
IN inewpassword varchar(255),
IN ifirstflag int(11),
IN iisadminreset int(11),
IN ipasswordlimit int(11),
IN icreateraction varchar(255),
IN iadminpassword int(11),
OUT omess varchar(255))
BEGIN


Declare tuserStatusIdActive int(11);
Declare tuserStatusIdInactive int(11);
Declare topassword varchar(255);
Declare tnpassword varchar(255);
Declare tvaliduserid int(11);
Declare tpasscnt int(11);
Declare tmaxpass int(11) default 0;
Declare tactiondesc varchar(320);
Declare taactivityid int(11);
Declare tbothflags int(11) default 0;
Declare tflagreset int(11);
Declare tRowsCount int(11) default 0;
Declare tuseraction varchar(255);
Declare tvaliduserpass int(11);





SELECT statusid into tuserStatusIdActive FROM apmmasterrecordsstate  where recordstate='Active';
SELECT statusid into tuserStatusIdInactive FROM apmmasterrecordsstate  where recordstate='Inactive';


set tmaxpass = ipasswordlimit;

-- iisadminreset = 0 for change password
-- iisadminreset = 1 for forgot password and first login
-- iisadminreset = 2 for admin reset

if iisadminreset = 0 then

  set tbothflags = 0;
  set tuseraction = 'Change Password';

elseif iisadminreset = 1 then

  set tbothflags = 0;
  if ifirstflag = 1 then
    set tuseraction = 'Forgot Password';
  else
    set tuseraction = 'First Login';
  end if;

elseif iisadminreset = 2 then

  set tbothflags = 2;
  set tuseraction = 'Reset Password';

end if;


set topassword = sha2(ioldpassword, 256);
set tnpassword = sha2(inewpassword, 256);

if iisadminreset = 2 then

  update apmpasswordhistory set statusid = tuserStatusIdInactive where userid = iuserid;

  insert into apmpasswordhistory(userid, userpassword, createddatetime, statusid)
    values
    (iuserid, tnpassword,now(),tuserStatusIdActive);

    select row_count() into tRowsCount;

    if tRowsCount > 0 then

      update apmusers set `password` = tnpassword, statusid =  tuserStatusIdActive  where userid = iuserid;

      set tactiondesc = concat('Admin with userid ', iadminpassword, ' has updated password for userid ',iuserid);

      select FNapmwriteactivitylog(iuserid , tuseraction, icreateraction , tactiondesc) into taactivityid;

      select FNapmsetfirstpassflag(iuserid , 1, 0 , 0) into tflagreset;
      set omess = '1#Successfully updated password.';

    else

      set tactiondesc = concat('Admin with userid ', iadminpassword, ' has tried to updated password for userid ',iuserid);

      select FNapmwriteactivitylog(iuserid , tuseraction, icreateraction , tactiondesc) into taactivityid;


      set omess = '0#Failed to update password';
    end if;

else
  select isfirstpass into tvaliduserpass from apmusers where userid = iuserid and statusid = tuserStatusIdActive;
   if ifirstflag = 0 and iisadminreset = 1 and tvaliduserpass = 0 then

          set omess = '4# User already activated his account.';
   elseif iisadminreset = 0 and tvaliduserpass = 1 then

          set omess = '5# Flag was reseted, logout and change the password.';
   else
    if iisadminreset = 1 then

      if ifirstflag = 1 then
        select distinct a.userid into tvaliduserid from apmusers a, apmpasswordhistory b where a.userid = iuserid and a.userid = b.userid
        and a.statusid = b.statusid and a.statusid = tuserStatusIdActive;
      else
 -- select "Here";
        select distinct a.userid into tvaliduserid from apmusers a, apmpasswordhistory b where a.userid = iuserid and a.userid = b.userid
        and a.password = topassword and a.statusid = b.statusid and a.statusid = tuserStatusIdActive;
      end if;

    else

      select distinct a.userid into tvaliduserid from apmusers a, apmpasswordhistory b where a.userid = iuserid and a.userid = b.userid
      and a.password = topassword and a.statusid = b.statusid and a.statusid = tuserStatusIdActive;

    end if;

--  select distinct a.userid into tvaliduserid from apmusers a, apmpasswordhistory b where a.userid = iuserid and a.userid = b.userid
--  and a.password = topassword and a.statusid = b.statusid and a.statusid = tuserStatusIdActive;

  if tvaliduserid != 0 then



    select count(userpass) into tpasscnt
    from (select userpassword as userpass from apmpasswordhistory where
    userid = tvaliduserid ORDER BY psid DESC LIMIT 0,tmaxpass) as obj where userpass=tnpassword;

    if tpasscnt = 0 then

      update apmusers set password = tnpassword where userid = tvaliduserid and statusid=tuserStatusIdActive;

      select row_count() into tRowsCount;

      if tRowsCount > 0 then

        update apmpasswordhistory set statusid = tuserStatusIdInactive where userid = iuserid;

        insert into apmpasswordhistory(userid, userpassword, createddatetime, statusid)
        values
        (tvaliduserid, tnpassword,now(),tuserStatusIdActive);

        set tactiondesc = concat('User has updated his password with userid ',tvaliduserid);
        select FNapmwriteactivitylog(iuserid , tuseraction, icreateraction , tactiondesc) into taactivityid;

        if iisadminreset = 1 then

          select FNapmsetfirstpassflag(iuserid , ifirstflag, tbothflags , 0) into tflagreset;

        end if;

       set omess = '1#Successfully updated password.';

      else
        set tactiondesc = concat('User has tried to update his password with userid ',tvaliduserid);
        select FNapmwriteactivitylog(iuserid , tuseraction, icreateraction , tactiondesc) into taactivityid;

       set omess = '0#Failed to update password.';


      end if;




  else

    set tactiondesc = concat('Password repetition limit exceeded with userid ',tvaliduserid);
    select FNapmwriteactivitylog(iuserid , tuseraction, icreateraction , tactiondesc) into taactivityid;

     set omess = '2#Password already has been used. Please choose another.';

    end if;

  else
-- select tfirstpass;

       set omess = '3# Invalid Old Password.';

  end if;
end if;

end if;


END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `SPapmchangeuserstatus`(
IN iuserid int(11),
IN ilockstatus int(1),
IN iunlockstatus int(1),
IN ideletestatus int(1),
IN iaction varchar(255),
IN iadminuserid int(11),
OUT omess varchar(255)
)
BEGIN




DECLARE tactivestatus int(11);
DECLARE tlockstatus int(11);
DECLARE tdeletestatus int(11);
DECLARE taactivityid int(11);
DECLARE tuseraction varchar(255);
DECLARE tactiondesc varchar(255);
DECLARE tusername varchar(255);
DECLARE temail varchar(255);

SELECT statusid into tactivestatus FROM apmmasterrecordsstate  where recordstate='Active';
SELECT statusid into tlockstatus FROM apmmasterrecordsstate  where recordstate='Locked';
SELECT statusid into tdeletestatus FROM apmmasterrecordsstate  where recordstate='Deleted';


select concat(firstname, ' ', lastname) into tusername from apmusers where userid = iuserid;
select emailid into temail from apmusers where userid = iuserid;

if ilockstatus = 1 and iunlockstatus = 0 and ideletestatus = 0 then
  set tuseraction = 'Lock user';

  update apmusers set statusid = tlockstatus where userid = iuserid;

  set tactiondesc = concat('User with userid ',iuserid, ' was Locked by admin with userid ', iadminuserid);
  select FNapmwriteactivitylog(iuserid , tuseraction, iaction , tactiondesc) into taactivityid;


elseif ilockstatus = 0 and iunlockstatus = 1 and ideletestatus = 0 then

  set tuseraction = 'Unlock user';

  update apmusers set statusid = tactivestatus, passcounter = 0 where userid = iuserid;

  set tactiondesc = concat('User with userid ',iuserid, ' was Activated by admin with userid ', iadminuserid);
  select FNapmwriteactivitylog(iuserid , tuseraction, iaction , tactiondesc) into taactivityid;


elseif ilockstatus = 0 and iunlockstatus = 0 and ideletestatus = 1 then

  set tuseraction = 'Delete user';

  update apmusers set statusid = tdeletestatus, deleteddatetime = now() where userid = iuserid;


  set tactiondesc = concat('User with userid ',iuserid, ' was Deleted by admin with userid ', iadminuserid);
  select FNapmwriteactivitylog(iuserid , tuseraction, iaction , tactiondesc) into taactivityid;


end if;

  set omess = concat('1#', tusername, '#', temail);
  select omess;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `SPapmchecksecurityqa`(
IN iaction varchar(255),
IN iuserid int(11),
IN isecureid int(11),
IN ianswer varchar(255),
IN imaxanshits int(11),
IN iforgot int(1),
OUT omess varchar(255))
BEGIN


Declare tQuestionStatusIdActive int(11);
Declare tUserStatusIdLocked int(11);
Declare taactivityid int(11);
Declare tactiondesc varchar(300);
Declare trowcount int(11) default 0;
Declare tcount int(11);
Declare twrongseccount int(11) default 0;
Declare tCountlog int(11);
Declare tCheckstatus int(11);
Declare tuseraction varchar(255);


if iforgot = 1 then
  set tuseraction = 'Forgot Password';
elseif iforgot = 0 then
  set tuseraction = 'Answer security questions';
end if;


SELECT statusid into tQuestionStatusIdActive FROM apmmasterrecordsstate  where recordstate='Active';
SELECT statusid into tUserStatusIdLocked FROM apmmasterrecordsstate  where recordstate='Locked';



if iforgot = 1 then

  select count(answerid) into trowcount from apmsecurityqa where answerid = isecureid and answer = sha2(ianswer, 256) and userid = iuserid;


else

  select count(answerid) into trowcount from apmsecurityqa where securityquestionid = isecureid and answer = sha2(ianswer, 256) and userid = iuserid;

end if;

  if trowcount <> 0 then

    if iforgot = 1 then

      set tactiondesc = concat('User applied for forgotpassword with userid ',iuserid, ' and questionid ',isecureid);
      set omess = concat(trowcount, '#Successfully set password');

    elseif iforgot = 0 then

      set tactiondesc = concat('User has logged in with userid ',iuserid, ' and questionid ',isecureid);
      set omess = concat(trowcount, '#Successfully logged in');

    end if;

    select FNapmwriteactivitylog(iuserid , tuseraction, iaction , tactiondesc) into taactivityid;

  else
          select statusid into tCheckstatus from apmusers where userid = iuserid;
    if tCheckstatus = tUserStatusIdLocked then
      set omess = '2#User has been locked. Please contact local administrator.';
    else
      if imaxanshits <> 0 then
          select seccounter into tCountlog from apmusers where userid = iuserid and statusid = tQuestionStatusIdActive;

          if tCountlog >= (imaxanshits - 1) then
            update apmusers set statusid = tUserStatusIdLocked where userid = iuserid;
            update apmusers set seccounter = 0 where userid = iuserid;

           set tactiondesc = concat('User with userid ',iuserid, ' was locked for entering wrong answer ',imaxanshits, ' times');
           select FNapmwriteactivitylog(iuserid , tuseraction, iaction , tactiondesc) into taactivityid;

           set omess = '2#User has been locked. Please contact local administrator.';

          else
            set twrongseccount = tCountlog + 1;
            update apmusers set seccounter = twrongseccount where userid = iuserid;

           set tactiondesc = concat('User with userid ',iuserid, ' has entered wrong answer ',twrongseccount, ' times');
           select FNapmwriteactivitylog(iuserid , tuseraction, iaction , tactiondesc) into taactivityid;

            set omess = '0#Invalid answer.';

          end if;
      else
          set tactiondesc = concat('Invalid security answer for userid ',iuserid);
          select FNapmwriteactivitylog(iuserid , tuseraction, iaction , tactiondesc) into taactivityid;
          set omess = concat(trowcount, '#Invalid answer');
          set omess = '0#Invalid answer.';
      end if;

    end if;

  end if;







END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `SPapmcheckuser`(
IN iusername varchar(255),
IN ipassword varchar(255),
IN iaction varchar(255),
IN icontrollername varchar(255),
IN imodulename varchar(255),
IN imaxpasshits int(11),
IN iuserid int(11))
BEGIN



Declare tUserStatusIdActive int(11);
Declare tUserStatusIdLocked int(11);
Declare tUserStatusIdDeleted int(11);
Declare tUserId int(11) default 0;
Declare taactivityid int(11);
Declare tactiondesc varchar(300);
Declare tUserpassId int(11) default 0;
Declare tpassexpiry int(11);
Declare tCountlog int(11);
Declare tStatusCheck int(11);
Declare twrongpasscount int(11) default 0;
Declare opassexpiry int(11);
Declare omess varchar(255);
Declare tuseraction varchar(255);
Declare tusername varchar(255);

SELECT statusid into tUserStatusIdActive FROM apmmasterrecordsstate  where recordstate='Active';
SELECT statusid into tUserStatusIdLocked FROM apmmasterrecordsstate  where recordstate='Locked';
SELECT statusid into tUserStatusIdDeleted FROM apmmasterrecordsstate  where recordstate='Deleted';


set tuseraction = 'Login';


if iuserid is not NULL then

  select count(d.firstname) as cnt
  from apmmasterroles a, apmuserrolemapping c, apmusers d
  where d.userid=iuserid and d.statusid=tUserStatusIdActive
   and
   c.userid = d.userid
   and c.statusid = d.statusid
   and a.roleid=c.roleid;
   set tactiondesc = concat('User activity is checked with ',iuserid);
   select FNapmwriteactivitylog(iuserid , tuseraction, iaction , tactiondesc) into taactivityid;

else


  select count(userid) into tUserId from apmusers where userloginid = iusername;

  if tUserId = 0 then

     set opassexpiry = 0;
     set omess = '3#User Name is Not matching';
     select opassexpiry, omess;

  else

     select userid into tUserId from apmusers where userloginid = iusername;
     -- select count(userid) into tUserpassId from apmusers where userloginid = iusername and password = sha2(ipassword,256) and statusid = tUserStatusIdActive;
     -- select concat(firstname, ' ', lastname) into tusername from apmusers where userloginid = iusername and password = sha2(ipassword,256) and statusid = tUserStatusIdActive;
     select count(userid) into tUserpassId from apmusers where userloginid = iusername and password = ipassword and statusid = tUserStatusIdActive;
     select concat(firstname, ' ', lastname) into tusername from apmusers where userloginid = iusername and password = ipassword and statusid = tUserStatusIdActive;

     if tUserpassId = 0 then

        select statusid into tStatusCheck from apmusers where userloginid = iusername;

        if tStatusCheck = tUserStatusIdLocked then

            set opassexpiry = 0;
            set omess = '2#User has been locked. Please contact local administrator.';
            set tactiondesc = concat('User has been already locked for ',tUserId);
            select FNapmwriteuseractivitylog(tUserId , tuseraction, iaction ,icontrollername ,imodulename, tactiondesc) into taactivityid;
            select opassexpiry, omess;

        elseif tStatusCheck = tUserStatusIdDeleted then

           set opassexpiry = 0;
           set omess = '4#User no longer exists.';
           set tactiondesc = concat('Trying to login for deleted user with ',tUserId);
           select FNapmwriteuseractivitylog(tUserId , tuseraction, iaction ,icontrollername ,imodulename, tactiondesc) into taactivityid;
           select opassexpiry, omess;

        else

        if imaxpasshits <> 0 then

          select passcounter into tCountlog from apmusers where userid = tUserId and statusid = tUserStatusIdActive;

          if tCountlog >= (imaxpasshits - 1) then

            update apmusers set statusid = tUserStatusIdLocked, passcounter = 0 where userid = tUserId;

            set tactiondesc = concat('Invalid password for ',tUserId);
            select FNapmwriteuseractivitylog(tUserId , tuseraction, iaction ,icontrollername ,imodulename, tactiondesc) into taactivityid;
            set opassexpiry = 0;
            set omess = '2#User has been locked. Please contact local administrator.';
            set tactiondesc = concat('User has been locked for ',tUserId);
            select FNapmwriteuseractivitylog(tUserId , tuseraction, iaction ,icontrollername ,imodulename, tactiondesc) into taactivityid;
            select opassexpiry, omess;

          else

            set twrongpasscount = tCountlog + 1;
            update apmusers set passcounter = twrongpasscount where userid = tUserId;

            set tactiondesc = concat('Invalid password for ',tUserId);
            select FNapmwriteuseractivitylog(tUserId , tuseraction, iaction ,icontrollername ,imodulename, tactiondesc) into taactivityid;
            set opassexpiry = 0;
            set omess = '0#Invalid Password entered.';
            select opassexpiry, omess;

          end if;

        else

          set tactiondesc = concat('Invalid password for ',tUserId);
          select FNapmwriteuseractivitylog(tUserId , tuseraction, iaction ,icontrollername ,imodulename, tactiondesc) into taactivityid;
          set opassexpiry = 0;
          set omess = '0#Invalid Password.';
          select opassexpiry, omess;

        end if; 

      end if; 

     else

       select DATEDIFF(now(), (select updateddatetime from apmpasswordhistory where userid=tUserId and statusid = tUserStatusIdActive order by updateddatetime desc limit 0,1)) into tpassexpiry ;
        
        update apmusers set passcounter = 0, seccounter = 0 where userid = tUserId;

       set tactiondesc = concat('User succefully logged in with ',tUserId);

       select FNapmwriteuseractivitylog(tUserId , tuseraction, iaction ,icontrollername ,imodulename, tactiondesc) into taactivityid;

        set opassexpiry = tpassexpiry;

       set omess = '1#User succefully logged in.';

select a.rolename as role, a.roleid as roleid, a.priority as priority,
       d.userid as userid, count(d.firstname) as cnt, d.isfirstpass as isfirstpass, d.emailid as email, d.issecured as issecured,
       concat(d.firstname, ' ', d.lastname) as name, opassexpiry, omess
       from apmmasterroles a, apmuserrolemapping c, apmusers d
       where
       d.userid=tUserId
       and d.statusid= tUserStatusIdActive
       and c.userid = d.userid and a.roleid=c.roleid;



     end if;



  end if;

end if;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `SPapmcheckuserexistance`(
IN iusername varchar(255),
IN iuseraction varchar(255)
)
BEGIN



Declare tUserStatusIdActive int(11);
Declare tUserStatusIdLocked int(11);
Declare tUserStatusIdDeleted int(11);
Declare tuserid int(11) default 0;
Declare tactiondesc varchar(255);
Declare tuseraction varchar(255);
Declare taactivityid int(11);

SELECT statusid into tUserStatusIdActive FROM apmmasterrecordsstate  where recordstate='Active';
SELECT statusid into tUserStatusIdLocked FROM apmmasterrecordsstate  where recordstate='Locked';
SELECT statusid into tUserStatusIdDeleted FROM apmmasterrecordsstate  where recordstate='Deleted';



select userid into tuserid from apmusers where userloginid = iusername and statusid = tUserStatusIdActive;

if tuserid = 0 then

  if iuseraction is null then

    select userid, count(userid) as cnt from apmusers where userloginid = iusername;

  else

    select userid, count(userid) as cnt from apmusers where userloginid = iusername and statusid = tUserStatusIdActive;

  end if;

else

  set tuseraction = 'Forgot Password';
  select userid, firstname, lastname, count(userid) as cnt, issecured, emailid from apmusers where userloginid = iusername and statusid = tUserStatusIdActive;
  set tactiondesc = concat('forgot user password for the id ',tuserid);
  select FNapmwriteactivitylog(tuserid , tuseraction, iuseraction , tactiondesc) into taactivityid;

end if;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `SPapmcountofusers`(
IN iusername varchar(255),
IN ifirstname varchar(255),
IN ilastname varchar(255),
IN irole int(11),
IN iuserid int(11)
)
BEGIN


Declare tuserStatusIdDeleted int(11);
declare tcond text;

SELECT statusid into tuserStatusIdDeleted FROM apmmasterrecordsstate  where recordstate='Deleted';

set tcond = '';

if iusername <> '0' then

  set tcond = concat(tcond," and  a.userloginid like '%", iusername , "%'");

end if;

if ifirstname <> '0' then

  set tcond = concat(tcond," and a.firstname like '%", ifirstname , "%'");

end if;

if ilastname <> '0' then

  set tcond = concat(tcond," and a.lastname like '%", ilastname , "%'");

end if;

if irole <> 0 then

  set tcond = concat(tcond," and d.roleid =", irole);

end if;



  set @tstatement=concat("select count(a.userid) as tusercount from apmusers a, apmmasterroles c, apmmasterrecordsstate b, apmuserrolemapping d
  where a.statusid !=", tuserStatusIdDeleted," and a. userid = d.userid and c.roleid = d.roleid and a.statusid = b.statusid
  and a.userid <> ",iuserid , tcond);



PREPARE stmt_name FROM @tstatement;
EXECUTE stmt_name;


END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `SPapmcreateuser`(
IN ifirstname varchar(255),
IN ilastname varchar(255),
IN iemailid varchar(255),
IN ipassword varchar(255),
IN iusername varchar(255),
IN iphonenumber double(10,0),
IN iuserrole int(11),
IN imerchant_id int(11),
IN iaction varchar(255),
IN iadmin int(11)
)
BEGIN





declare tcountcheck int(11) default 0;
declare tcuruseraction varchar(255);
declare tactiondesc varchar(255);
declare tusercount int(5) default 0;
declare tsuccess int(11);
declare tcount int(11);
declare tuserid int(11);
declare tUserStatusIdActive int(11);
declare taactivityid int(11);
declare toutput varchar(255);
declare tappid int(11);
declare trolename varchar(100);




set tcuruseraction = 'Add User';
set tactiondesc = '';


SELECT statusid into tUserStatusIdActive FROM apmmasterrecordsstate  where recordstate='Active';

-- select appid into tappid from apmmasterapps where appname = iapp and statusid = tUserStatusIdActive;

-- select a.usertypeid into tcount from apmmasterusertypes a, apmmasterroles b where a.usertypeid = b.usertypeid and b.roleid = iuserrole;

select count(emailid) into tusercount from apmusers where userloginid = iusername;

if tusercount <> 0 then
    set tactiondesc = concat('Unable to create user with email ', iemailid , ' as the email already exists.');
    set toutput = '0#Failed to register User';

else
        /*insert into apmusers(firstname, lastname, emailid, password, userloginid, phonenumber, createddatetime, statusid)
        values
        (ifirstname, ilastname, iemailid, SHA2(ipassword, 256), iusername, iphonenumber, NOW(), tUserStatusIdActive);
        */

        insert into apmusers(firstname, lastname, emailid, password, userloginid, phonenumber, createddatetime, statusid)
        values
        (ifirstname, ilastname, iemailid, ipassword, iusername, iphonenumber, NOW(), tUserStatusIdActive);
        select LAST_INSERT_ID() into tuserid;

        /*
        insert into apmpasswordhistory(userid, userpassword, createddatetime, statusid)
        values
        (tuserid,  SHA2(ipassword, 256), now(), tUserStatusIdActive);
        */

        insert into apmpasswordhistory(userid, userpassword, createddatetime, statusid)
        values
        (tuserid,  ipassword, now(), tUserStatusIdActive);

        insert into apmuserrolemapping(roleid, userid, createddatetime, statusid)
        values
        (iuserrole, tuserid, NOW(), tUserStatusIdActive);
        select rolename into trolename from apmmasterroles where roleid = iuserrole;

        if imerchant_id<>'' then
            insert into store_merchants_users(merchant_id, userid, createddatetime, statusid)
            values
            (imerchant_id, tuserid, NOW(), tUserStatusIdActive);
        end if;

    


          set tactiondesc = concat('User created with email ', iemailid, ' and userid ', iusername , ' by admin ', iadmin);
          set toutput = concat('1#', trolename, '#User Registered successfully');
  
  
  
  

end if;



select FNapmwriteactivitylog(tuserid , tcuruseraction, iaction , tactiondesc) into taactivityid;

  
select toutput;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `SPapmfetchemailtemplate`(
IN itemplatename varchar(255),
IN iresellername varchar(255),
IN iappname varchar(255)
)
BEGIN

Declare ttemplateactive int(11);
declare tresellerid int(11);
declare tappid int(11);



-- select resellerid into tresellerid from apmresellers where resellername=iresellername;
-- SELECT appid into tappid FROM apmmasterapps where appname=iappname;
select statusid into ttemplateactive from apmmasterrecordsstate where recordstate = 'Active';

select emailtemplateid, emailtemplatename, emailcontent, emailsubject, emailfrom from apmemailtemplate where emailtemplatename = itemplatename and statusid =ttemplateactive;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `SPapmfetchsecurityquestions`(IN iuserid int(11))
BEGIN


Declare tQuestionStatusIdActive int(11);
Declare tsecqnid int(11) default 0;

SELECT statusid into tQuestionStatusIdActive FROM apmmasterrecordsstate  where recordstate='Active';

if iuserid is null then

  SELECT securityquestionid, securityquestion FROM apmmastersecurityquestions where statusid=tQuestionStatusIdActive;

else

  select securityquestionid into tsecqnid from apmsecurityqa where userid=iuserid and statusid=tQuestionStatusIdActive;

  if tsecqnid > 0 then

    select a.securityquestionid, a.securityquestion
    from apmmastersecurityquestions a, apmsecurityqa b
    where b.userid=iuserid and a.statusid=b.statusid and
    a.securityquestionid = b.securityquestionid and b.statusid = tQuestionStatusIdActive;

  else

    select answerid as securityquestionid, securityquestion from apmsecurityqa where userid=iuserid and statusid=tQuestionStatusIdActive;

  end if;

end if;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `SPapmgetcontrollers`(
IN imoduleid int(11)
)
BEGIN


Declare tmoduleStatusIdActive int(11);

SELECT statusid into tmoduleStatusIdActive FROM apmmasterrecordsstate  where recordstate='Active';

-- select controllerid, controllername from apmmastercontrollers where moduleid = imoduleid AND statusid=tmoduleStatusIdActive;
select c.controllerid, c.controllername, m.moduleid, m.modulename
from apmmastercontrollers c, apmmastermodules m
where
-- moduleid = imoduleid
c.moduleid = m.moduleid
AND
c.statusid=tmoduleStatusIdActive;


END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `SPapmgetmailqueue`()
BEGIN

Declare tmoduleStatusIdActive int(11);
Declare tmoduleStatusIdemailnotsent int(11);

SELECT statusid into tmoduleStatusIdActive FROM apmmasterrecordsstate  where recordstate='Active';
SELECT mailstatusid into tmoduleStatusIdemailnotsent FROM apmmastermailstatus  where mailstate='emailnotsent';


select * from apmmailqueue where statusid=tmoduleStatusIdActive and mailstatus=tmoduleStatusIdemailnotsent limit 0,9;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `SPapmgetmodules`()
BEGIN

Declare tmoduleStatusIdActive int(11);

SELECT statusid into tmoduleStatusIdActive FROM apmmasterrecordsstate  where recordstate='Active';

select moduleid, modulename from apmmastermodules where statusid=tmoduleStatusIdActive;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `SPapmgetrolprivileges`()
BEGIN


Declare tusertypeStatusIdActive int(11);

SELECT statusid into tusertypeStatusIdActive FROM apmmasterrecordsstate  where recordstate='Active';

select a.rolename, b.modulename, c.controllername, d.actionname from apmmasterroles a, apmmastermodules b, apmmastercontrollers c, apmmasteractions d,
apmmasterroleprivileges e where e.roleid = a.roleid and e.actionid=d.actionid and c.controllerid = d.controllerid and c.moduleid = b.moduleid
and e.statusid = tusertypeStatusIdActive
order by a.rolename, b.modulename, c.controllername, d.actionname;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `SPapmgetuserdetails`(IN iuserid int(11))
BEGIN



Declare tUserStatusIdActive int(11);

SELECT statusid into tUserStatusIdActive FROM apmmasterrecordsstate  where recordstate='Active';

  select a.rolename as role, d.firstname as firstname, d.lastname as lastname, d.emailid as username, d.phonenumber as phonenumber, d.userloginid as userloginid, a.roleid as roleid, a.priority as priority,
  -- b.usertypename as usertype, b.usertypeid as usertypeid,
     d.userid as userid, count(d.firstname) as cnt, d.isfirstpass as isfirstpass, d.issecured as issecured,
     concat(d.firstname, ' ', d.lastname) as name, d.statusid as stat
     from apmmasterroles a, apmuserrolemapping c, apmusers d
     where d.userid=iuserid
     and c.userid = d.userid and a.roleid=c.roleid;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `SPapmgetusers`(
IN iuserid int(11),
IN istart int(11),
IN ilimit int(11),
IN iusername varchar(255),
IN ifirstname varchar(255),
IN ilastname varchar(255),
IN irole int(11)
 )
BEGIN


Declare tuserStatusIdActive int(11);
Declare tuserStatusIdDeleted int(11);
Declare tusertype int(11);
declare tcond text;

SELECT statusid into tuserStatusIdActive FROM apmmasterrecordsstate  where recordstate='Active';
SELECT statusid into tuserStatusIdDeleted FROM apmmasterrecordsstate  where recordstate='Deleted';
-- select a.usertypeid into tusertype from apmmasterroles a, apmuserrolemapping b where b.userid = iuserid and a.roleid = b.roleid;


set tcond = '';

if iusername <> '0' then

  set tcond = concat(tcond," and  a.userloginid like '%", iusername , "%'");

end if;

if ifirstname <> '0' then

  set tcond = concat(tcond," and a.firstname like '%", ifirstname , "%'");

end if;

if ilastname <> '0' then

  set tcond = concat(tcond," and a.lastname like '%", ilastname , "%'");

end if;

if irole <> 0 then

  set tcond = concat(tcond," and d.roleid =", irole);

end if;

/*
set @tstatement=concat("select a.lastname as lname ,a.firstname as fname, a.userid as userid, a.emailid as email, a.userloginid as userloginid, b.recordstate as status,
 c.rolename as role from apmusers a, apmmasterroles c, apmmasterrecordsstate b, apmuserrolemapping d
where a.statusid !=", tuserStatusIdDeleted," and a. userid =d.userid and c.roleid = d.roleid
and a.statusid = b.statusid and a.userid !=", iuserid, tcond ," order by a.lastname, a.firstname limit ", istart,",", ilimit);


set @tstatement=concat("select a.lastname as lname ,a.firstname as fname, a.userid as userid, a.emailid as email, a.userloginid as userloginid, b.recordstate as status,
 c.rolename as role from apmusers a, apmmasterroles c, apmmasterrecordsstate b, apmuserrolemapping d
where a.statusid !=", tuserStatusIdDeleted," and a. userid =d.userid and c.roleid = d.roleid
and a.statusid = b.statusid and a.userid !=", iuserid, tcond ," order by a.lastname, a.firstname  ");
*/

set @tstatement=concat("select a.lastname as lname ,a.firstname as fname, a.userid as userid, a.emailid as email, a.userloginid as userloginid, b.recordstate as status,
 c.rolename as role from apmusers a, apmmasterroles c, apmmasterrecordsstate b, apmuserrolemapping d
where a.statusid !=", tuserStatusIdDeleted," and a. userid =d.userid and c.roleid = d.roleid
and a.statusid = b.statusid ", tcond ," order by a.lastname, a.firstname  ");




PREPARE stmt_name FROM @tstatement;
EXECUTE stmt_name;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `SPapmgetusertypesroles`()
BEGIN


Declare tusertypeStatusIdActive int(11);

SELECT statusid into tusertypeStatusIdActive FROM apmmasterrecordsstate  where recordstate='Active';


select
b.rolename as role,
b.priority as priority,
b.roleid as roleid
from apmmasterroles b where
b.statusid = tusertypeStatusIdActive order by b.priority;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `SPapmsavesecurityqueston`(
IN iquestion varchar(255),
IN ianswer varchar(255),
IN iuserid int(11),
IN iaction varchar(255),
IN iisupdate INT(1),
IN iadminuserid int(11),
OUT omess varchar(255))
BEGIN

Declare tQuestionStatusIdActive int(11);
Declare tflagreset int(11);
Declare taactivityid int(11);
Declare tactiondesc varchar(300);
Declare trowcount int(11) default 0;
Declare tcount int(11);
Declare tcuruseraction varchar(255);
Declare tfqaid int(11);
Declare tusername varchar(500);
Declare tsecure int(1);



SELECT statusid into tQuestionStatusIdActive FROM apmmasterrecordsstate  where recordstate='Active';
select concat(firstname, ' ', lastname) into tusername from apmusers where userid = iuserid;


if iisupdate = 2 then

  set tcuruseraction = 'Reset Security';
  select FNapmsetfirstpassflag(iuserid , 0, 1 , 0) into trowcount;

  set tactiondesc = concat('Admin with userid ', iadminuserid, ' resets security questions for userid ',iuserid);
  select FNapmwriteactivitylog(iuserid , tcuruseraction, iaction , tactiondesc) into taactivityid;

  set omess = concat('1#', tusername);



elseif iisupdate = 1 then

  set tcuruseraction = 'Update security questions';
  select issecured into tsecure from apmusers where userid = iuserid;
  if tsecure = 0 then
    set omess = concat('0#Security questions are updated successfully for ' , tusername);
  else

    select answerid into tfqaid from apmsecurityqa where userid = iuserid and statusid = tQuestionStatusIdActive limit 0,1;


    update apmsecurityqa set securityquestion = iquestion, answer = sha2(ianswer, 256) where answerid = tfqaid and userid = iuserid;

    select row_count() into trowcount;

    set tactiondesc = concat('Security questions were updated for userid ',iuserid);
    select FNapmwriteactivitylog(iuserid , tcuruseraction, iaction , tactiondesc) into taactivityid;


    if trowcount <> 0 then
      set omess = concat('1#Security questions are updated successfully for ' , tusername);
    else
      set omess = concat('1#Unable to update security questions ', tusername);
    end if;

  end if;

elseif iisupdate = 0 then
  set tcuruseraction = 'Register security questions';
  select count(userid) into tcount from apmsecurityqa where userid = iuserid and statusid = tQuestionStatusIdActive;

  if tcount = 0 then
    select FNapmsetfirstpassflag(iuserid , 0, 1 , 1) into tflagreset;
    insert into apmsecurityqa(userid, securityquestion, answer, createddatetime, statusid)
    values
    (iuserid, iquestion,sha2(ianswer, 256),now(),tQuestionStatusIdActive);
    select row_count() into trowcount;

    set tactiondesc = concat('Security questions were added for userid ',iuserid);
    select FNapmwriteactivitylog(iuserid , tcuruseraction, iaction , tactiondesc) into taactivityid;



    if trowcount <> 0 then
      set omess = concat(trowcount, '#Security questions are added successfully for ', tusername);
    else
      set omess = concat(trowcount, '#Unable to add security questions for ', tusername);
    end if;
  else
     set omess = concat('0#User already added security questions for ', tusername);
  end if;

end if;






END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `SPapmupdateuserdetails`(
IN iuserid int(11),
IN ifirstname varchar(255),
IN ilastname varchar(255),
IN iemail varchar(255),
IN iphonenumber double(10,0),
IN irole int(11),
IN iapp varchar(255),
IN iaction varchar(255),
IN iadmin int(11)
)
BEGIN

Declare tuserStatusIdActive int(11);
Declare tuserStatusIdDeleted int(11);
Declare tappid int(11);
Declare trowcount int(11);
Declare tactiondesc varchar(255);
Declare taactivityid int(11);
Declare tcuruseraction varchar(255);
Declare tmess varchar(255);
Declare tstatus int(11);


SELECT statusid into tuserStatusIdActive FROM apmmasterrecordsstate  where recordstate='Active';
SELECT statusid into tuserStatusIdDeleted FROM apmmasterrecordsstate  where recordstate='Deleted';
-- select appid into tappid from apmmasterapps where appname = iapp and statusid = tuserStatusIdActive;

select statusid into tstatus from apmusers where userid = iuserid;
if tstatus <> tuserStatusIdDeleted then

-- update apmusers set firstname = ifirstname, lastname = ilastname, emailid = iemail, phonenumber = iphonenumber where userid = iuserid;

update apmusers set firstname = ifirstname, lastname = ilastname, phonenumber = iphonenumber where userid = iuserid;


if iadmin <> 0 then

  -- update apmuserrolemapping set roleid = irole where userid = iuserid;
  set tcuruseraction = 'Edit user';
  set tactiondesc = concat('Details were updated for userid ',iuserid, ' by ', iadmin);

else

  set tcuruseraction = 'update personal info';
  set tactiondesc = concat('Details were updated by ',iuserid);

end if;

select FNapmwriteactivitylog(iuserid , tcuruseraction, iaction , tactiondesc) into taactivityid;
set tmess = '1#success';
select tmess;

else
  set tmess = '2#failure';
  select tmess;
end if;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `SPattributeadd`(
IN iattribute_title varchar(255),
IN iattribute_field_type varchar(255),
IN iattribute_data_type varchar(255),
IN iaction varchar(255),
IN iadmin int(11)
)
BEGIN


declare tcountcheck int(11) default 0;
declare tcuruseraction varchar(255);
declare tactiondesc varchar(255);
declare tattributecount int(5) default 0;
declare tsuccess int(11);
declare tcount int(11);
declare tattributeid int(11);
declare tUserStatusIdActive int(11);
declare taactivityid int(11);
declare toutput varchar(255);



set tcuruseraction = 'Add Attribute';
set tactiondesc = '';


SELECT statusid into tUserStatusIdActive FROM apmmasterrecordsstate  where recordstate='Active';



select count(attribute_id) into tattributecount from store_products_attributes where attribute_title = iattribute_title;

if tattributecount <> 0 then
    set tactiondesc = concat('Unable to create attribute with ', iattribute_title , ' as the attribute title already exists.');
    set toutput = '0#Failed to register attribute';

else


			insert into store_products_attributes
			(attribute_title,
			attribute_field_type,
			attribute_data_type,
			createddatetime,
			statusid)
			values
			(
			iattribute_title,
			iattribute_field_type,
			iattribute_data_type,
			NOW(),
			tUserStatusIdActive);

      select LAST_INSERT_ID() into tattributeid;


      set tactiondesc = concat('Attribute created with title ', iattribute_title, ' and attribute_id ', tattributeid , ' by admin ', iadmin);
      set toutput = concat('1#',tattributeid,'#', iattribute_title, '#Attribute Registered successfully');



end if;


      select FNapmwriteactivitylog(iadmin , tcuruseraction, iaction , tactiondesc) into taactivityid;


select toutput;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `SPattributechangestatus`(
IN iattribute_id int(11),
IN ilockstatus int(1),
IN iunlockstatus int(1),
IN ideletestatus int(1),
IN iaction varchar(255),
IN iadminid int(11),
OUT omess varchar(255)
)
BEGIN


DECLARE tactivestatus int(11);
DECLARE tlockstatus int(11);
DECLARE tdeletestatus int(11);
DECLARE taactivityid int(11);
DECLARE tcategoryaction varchar(255);
DECLARE tactiondesc varchar(255);
DECLARE tattribute_title varchar(255);



SELECT statusid into tactivestatus FROM apmmasterrecordsstate  where recordstate='Active';
SELECT statusid into tlockstatus FROM apmmasterrecordsstate  where recordstate='Locked';
SELECT statusid into tdeletestatus FROM apmmasterrecordsstate  where recordstate='Deleted';

select attribute_title into tattribute_title from store_products_attributes where attribute_id = iattribute_id;


if ilockstatus = 1 and iunlockstatus = 0 and ideletestatus = 0 then
  set tcategoryaction = 'Lock attribute';

  update store_products_attributes set statusid = tlockstatus where attribute_id = iattribute_id;

  set tactiondesc = concat('Attribute with attribute_id ',iattribute_id, ' was Locked by admin with adminid ', iadminid);
  select FNapmwriteactivitylog(iadminid , tcategoryaction, iaction , tactiondesc) into taactivityid;


elseif ilockstatus = 0 and iunlockstatus = 1 and ideletestatus = 0 then

  set tcategoryaction = 'Unlock attribute';

  update store_products_attributes set statusid = tactivestatus where attribute_id = iattribute_id;

  set tactiondesc = concat('Attribute with attribute_id ',iattribute_id, ' was Activated by admin with adminid ', iadminid);
  select FNapmwriteactivitylog(iadminid , tcategoryaction, iaction , tactiondesc) into taactivityid;


elseif ilockstatus = 0 and iunlockstatus = 0 and ideletestatus = 1 then

  set tcategoryaction = 'Delete attribute';

  update store_products_attributes set statusid = tdeletestatus, deleteddatetime = now() where attribute_id = iattribute_id;


  set tactiondesc = concat('Attribute with attribute_id ',iattribute_id, ' was Deleted by admin with adminid ', iadminid);
  select FNapmwriteactivitylog(iadminid , tcategoryaction, iaction , tactiondesc) into taactivityid;


end if;

  set omess = concat('1#', tattribute_title, '#', '');
  select omess;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `SPattributedetails`(
IN iattribute_id int(11)
)
BEGIN

set @tstatement=concat("SELECT * FROM store_products_attributes  where attribute_id = ", iattribute_id);
-- select @tstatement;

PREPARE stmt_name FROM @tstatement;
EXECUTE stmt_name;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `SPattributeedit`(
IN iattribute_id int(11),
IN iattribute_title varchar(255),
IN iattribute_field_type varchar(255),
IN iattribute_data_type varchar(255),
IN iaction varchar(255),
IN iadmin int(11)
)
BEGIN

Declare tuserStatusIdActive int(11);
Declare tuserStatusIdDeleted int(11);
Declare trowcount int(11);
Declare tactiondesc varchar(255);
Declare taactivityid int(11);
Declare tcuruseraction varchar(255);
Declare tmess varchar(255);
Declare tstatus int(11);


SELECT statusid into tuserStatusIdActive FROM apmmasterrecordsstate  where recordstate='Active';
SELECT statusid into tuserStatusIdDeleted FROM apmmasterrecordsstate  where recordstate='Deleted';


select statusid into tstatus from store_products_attributes where attribute_id = iattribute_id;
if tstatus <> tuserStatusIdDeleted then

      update store_products_attributes set
      attribute_title         = iattribute_title,
      attribute_field_type    = iattribute_field_type,
      attribute_data_type     = iattribute_data_type
      where attribute_id      = iattribute_id;

      set tcuruseraction = 'Edit attribute';
      set tactiondesc = concat('Details were updated for attribute_id ',iattribute_id, ' by ', iadmin);



      select FNapmwriteactivitylog(iadmin , tcuruseraction, iaction , tactiondesc) into taactivityid;
      set tmess = '1#success';
      select tmess;

else
  set tmess = '2#failure';
  select tmess;
end if;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `SPattributegroupadd`(
IN iattributes_group_title varchar(255),
IN iaction varchar(255),
IN iadmin int(11)
)
BEGIN


declare tcountcheck int(11) default 0;
declare tcuruseraction varchar(255);
declare tactiondesc varchar(255);
declare tattributegroupcount int(5) default 0;
declare tsuccess int(11);
declare tcount int(11);
declare tattributegroupid int(11);
declare tUserStatusIdActive int(11);
declare taactivityid int(11);
declare toutput varchar(255);



set tcuruseraction = 'Add Attribute Group';
set tactiondesc = '';


SELECT statusid into tUserStatusIdActive FROM apmmasterrecordsstate  where recordstate='Active';



select count(attributes_group_id) into tattributegroupcount from store_products_attributes_groups where attributes_group_title = iattributes_group_title;

if tattributegroupcount <> 0 then
    set tactiondesc = concat('Unable to create attribute group with ', iattributes_group_title , ' as the attribute group title already exists.');
    set toutput = '0#Failed to register attribute group';

else


			insert into store_products_attributes_groups
			(attributes_group_title,
			createddatetime,
			statusid)
			values
			(
			iattributes_group_title,
			NOW(),
			tUserStatusIdActive);

      select LAST_INSERT_ID() into tattributegroupid;


      set tactiondesc = concat('Attribute group created with title ', iattributes_group_title, ' and attributes_group_id ', tattributegroupid , ' by admin ', iadmin);
      set toutput = concat('1#',tattributegroupid,'#', iattributes_group_title, '#Attribute Group Registered successfully');



end if;


      select FNapmwriteactivitylog(iadmin , tcuruseraction, iaction , tactiondesc) into taactivityid;


select toutput;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `SPattributegroupchangestatus`(
IN iattributes_group_id int(11),
IN ilockstatus int(1),
IN iunlockstatus int(1),
IN ideletestatus int(1),
IN iaction varchar(255),
IN iadminid int(11),
OUT omess varchar(255)
)
BEGIN


DECLARE tactivestatus int(11);
DECLARE tlockstatus int(11);
DECLARE tdeletestatus int(11);
DECLARE taactivityid int(11);
DECLARE tattributeaction varchar(255);
DECLARE tactiondesc varchar(255);
DECLARE tattributes_group_title varchar(255);



SELECT statusid into tactivestatus FROM apmmasterrecordsstate  where recordstate='Active';
SELECT statusid into tlockstatus FROM apmmasterrecordsstate  where recordstate='Locked';
SELECT statusid into tdeletestatus FROM apmmasterrecordsstate  where recordstate='Deleted';

select attributes_group_title into tattributes_group_title from store_products_attributes_groups where attributes_group_id = iattributes_group_id;


if ilockstatus = 1 and iunlockstatus = 0 and ideletestatus = 0 then
  set tattributeaction = 'Lock attribute group';

  update store_products_attributes_groups set statusid = tlockstatus where attributes_group_id = iattributes_group_id;

  set tactiondesc = concat('Attribute group with attributes_group_id ',iattributes_group_id, ' was Locked by admin with adminid ', iadminid);
  select FNapmwriteactivitylog(iadminid , tattributeaction, iaction , tactiondesc) into taactivityid;


elseif ilockstatus = 0 and iunlockstatus = 1 and ideletestatus = 0 then

  set tattributeaction = 'Unlock attribute group';

  update store_products_attributes_groups set statusid = tactivestatus where attributes_group_id = iattributes_group_id;

  set tactiondesc = concat('Attribute group with attributes_group_id ',iattributes_group_id, ' was Activated by admin with adminid ', iadminid);
  select FNapmwriteactivitylog(iadminid , tattributeaction, iaction , tactiondesc) into taactivityid;


elseif ilockstatus = 0 and iunlockstatus = 0 and ideletestatus = 1 then

  set tattributeaction = 'Delete attribute group';

  update store_products_attributes_groups set statusid = tdeletestatus, deleteddatetime = now() where attributes_group_id = iattributes_group_id;


  set tactiondesc = concat('Attribute group with attributes_group_id ',iattributes_group_id, ' was Deleted by admin with adminid ', iadminid);
  select FNapmwriteactivitylog(iadminid , tattributeaction, iaction , tactiondesc) into taactivityid;


end if;

  set omess = concat('1#', tattributes_group_title, '#', '');
  select omess;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `SPattributegroupdetails`(
IN iattribute_group_id int(11)
)
BEGIN

set @tstatement=concat("SELECT * FROM store_products_attributes_groups  where attributes_group_id = ", iattribute_group_id);
-- select @tstatement;

PREPARE stmt_name FROM @tstatement;
EXECUTE stmt_name;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `SPattributegroupedit`(
IN iattributes_group_id int(11),
IN iattributes_group_title varchar(255),
IN iaction varchar(255),
IN iadmin int(11)
)
BEGIN

Declare tuserStatusIdActive int(11);
Declare tuserStatusIdDeleted int(11);
Declare trowcount int(11);
Declare tactiondesc varchar(255);
Declare taactivityid int(11);
Declare tcuruseraction varchar(255);
Declare tmess varchar(255);
Declare tstatus int(11);


SELECT statusid into tuserStatusIdActive FROM apmmasterrecordsstate  where recordstate='Active';
SELECT statusid into tuserStatusIdDeleted FROM apmmasterrecordsstate  where recordstate='Deleted';


select statusid into tstatus from store_products_attributes_groups where attributes_group_id = iattributes_group_id;
if tstatus <> tuserStatusIdDeleted then

      update store_products_attributes_groups set
      attributes_group_title         = iattributes_group_title
      where attributes_group_id      = iattributes_group_id;

      set tcuruseraction = 'Edit attribute group';
      set tactiondesc = concat('Details were updated for attributes_group_id ',iattributes_group_id, ' by ', iadmin);



      select FNapmwriteactivitylog(iadmin , tcuruseraction, iaction , tactiondesc) into taactivityid;
      set tmess = '1#success';
      select tmess;

else
  set tmess = '2#failure';
  select tmess;
end if;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `SPattributegrouplist`(
IN iattribute_group_title varchar(255),
IN istart int(11),
IN ilimit int(11)
)
BEGIN


Declare tuserStatusIdActive int(11);
Declare tuserStatusIdDeleted int(11);
declare tcond text;

SELECT statusid into tuserStatusIdActive FROM apmmasterrecordsstate  where recordstate='Active';
SELECT statusid into tuserStatusIdDeleted FROM apmmasterrecordsstate  where recordstate='Deleted';


set tcond = '';

if iattribute_group_title <> '' then

  set tcond = concat(tcond," and  a.attributes_group_title like '%", iattribute_group_title , "%'");

end if;




set @tstatement=concat("select * from store_products_attributes_groups a, apmmasterrecordsstate b
where
a.statusid !=", tuserStatusIdDeleted," and a.statusid = b.statusid order by a.attributes_group_title ");


-- select @tstatement;

PREPARE stmt_name FROM @tstatement;
EXECUTE stmt_name;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `SPattributegroupmapsave`(
IN iattributes_group_id int(11),
IN iattributes_group_map text,
out omessage varchar(255)
)
BEGIN

Declare tuserStatusIdActive int(11);
SELECT statusid into tuserStatusIdActive FROM apmmasterrecordsstate  where recordstate='Active';

delete from store_products_attributes_sets_mapping where attributes_set_id IN (select attributes_set_id from store_products_attributes_sets where attributes_group_id = iattributes_group_id);

SELECT LENGTH(iattributes_group_map) - LENGTH(REPLACE(iattributes_group_map, '-', '')) into @iattributes_id_set_count;
-- select @iattributes_id_set_count;

WHILE @iattributes_id_set_count > 0 DO

      select sfSPLIT_STR(iattributes_group_map,'-',@iattributes_id_set_count) into @iattributes_id_set_each;

      -- select @iattributes_id_set_each;

      select sfSPLIT_STR(@iattributes_id_set_each,'#',1) into @iattributes_id_set_each_id;
      select sfSPLIT_STR(@iattributes_id_set_each,'#',2) into @iattributes_id_set_each_attribute_id;
      -- select @iattributes_id_set_each_id,'----',@iattributes_id_set_each_attribute_id;




          SELECT LENGTH(@iattributes_id_set_each_attribute_id) - LENGTH(REPLACE(@iattributes_id_set_each_attribute_id, ',', '')) into @iattributes_id_set_each_attribute_id_count;
          WHILE @iattributes_id_set_each_attribute_id_count > 0 DO

              select sfSPLIT_STR(@iattributes_id_set_each_attribute_id,',',@iattributes_id_set_each_attribute_id_count) into @iattributes_id_set_each_attribute_id_each;
              -- select @iattributes_id_set_each_attribute_id_each;

              insert into store_products_attributes_sets_mapping
              (attribute_id, attributes_set_id, createddatetime, statusid)
              values(@iattributes_id_set_each_attribute_id_each,@iattributes_id_set_each_id,NOW(),tUserStatusIdActive);


          SET @iattributes_id_set_each_attribute_id_count = @iattributes_id_set_each_attribute_id_count - 1;
          END WHILE;



      SET @iattributes_id_set_count = @iattributes_id_set_count - 1;
END WHILE;


set omessage = 'Updated successfully';

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `SPattributelist`(
IN iattribute_title varchar(255),
IN istart int(11),
IN ilimit int(11)
)
BEGIN


Declare tuserStatusIdActive int(11);
Declare tuserStatusIdDeleted int(11);
declare tcond text;

SELECT statusid into tuserStatusIdActive FROM apmmasterrecordsstate  where recordstate='Active';
SELECT statusid into tuserStatusIdDeleted FROM apmmasterrecordsstate  where recordstate='Deleted';


set tcond = '';

if iattribute_title <> '' then

  set tcond = concat(tcond," and  a.attribute_title like '%", iattribute_title , "%'");

end if;




-- set @tstatement=concat("select *, (select category_name from store_categories where category_id=c.parent_category_id) as parent_category_name from store_categories c, apmmasterrecordsstate b
-- where
-- c.statusid !=", tuserStatusIdDeleted," and c.statusid = b.statusid order by c.category_name limit ", istart,",", ilimit);


set @tstatement=concat("select * from store_products_attributes a, apmmasterrecordsstate b
where
a.statusid !=", tuserStatusIdDeleted," and a.statusid = b.statusid order by a.attribute_title ");


-- select @tstatement;

PREPARE stmt_name FROM @tstatement;
EXECUTE stmt_name;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `SPattributesetschangestatus`(
IN iattributes_set_id int(11),
IN ilockstatus int(1),
IN iunlockstatus int(1),
IN ideletestatus int(1),
IN iaction varchar(255),
IN iadminid int(11),
OUT omess varchar(255)
)
BEGIN


DECLARE tactivestatus int(11);
DECLARE tlockstatus int(11);
DECLARE tdeletestatus int(11);
DECLARE taactivityid int(11);
DECLARE tattributesetsaction varchar(255);
DECLARE tactiondesc varchar(255);
DECLARE tattributes_set_title varchar(255);



SELECT statusid into tactivestatus FROM apmmasterrecordsstate  where recordstate='Active';
SELECT statusid into tlockstatus FROM apmmasterrecordsstate  where recordstate='Locked';
SELECT statusid into tdeletestatus FROM apmmasterrecordsstate  where recordstate='Deleted';

select attributes_set_title into tattributes_set_title from store_products_attributes_sets where attributes_set_id = iattributes_set_id;


if ilockstatus = 1 and iunlockstatus = 0 and ideletestatus = 0 then
  set tattributesetsaction = 'Lock attributesets';

  update store_products_attributes_sets set statusid = tlockstatus where attributes_set_id = iattributes_set_id;

  set tactiondesc = concat('Attributesets with attributes_set_id ',iattributes_set_id, ' was Locked by admin with adminid ', iadminid);
  select FNapmwriteactivitylog(iadminid , tattributesetsaction, iaction , tactiondesc) into taactivityid;


elseif ilockstatus = 0 and iunlockstatus = 1 and ideletestatus = 0 then

  set tattributesetsaction = 'Unlock attributesets';

  update store_products_attributes_sets set statusid = tactivestatus where attributes_set_id = iattributes_set_id;

  set tactiondesc = concat('Attributesets with attributes_set_id ',iattributes_set_id, ' was Activated by admin with adminid ', iadminid);
  select FNapmwriteactivitylog(iadminid , tattributesetsaction, iaction , tactiondesc) into taactivityid;


elseif ilockstatus = 0 and iunlockstatus = 0 and ideletestatus = 1 then

  set tattributesetsaction = 'Delete attributesets';

  update store_products_attributes_sets set statusid = tdeletestatus, deleteddatetime = now() where attributes_set_id = iattributes_set_id;


  set tactiondesc = concat('Attributesets with attributes_set_id ',iattributes_set_id, ' was Deleted by admin with adminid ', iadminid);
  select FNapmwriteactivitylog(iadminid , tattributesetsaction, iaction , tactiondesc) into taactivityid;


end if;

  set omess = concat('1#', tattributes_set_title, '#', '');
  select omess;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `SPattributesetscount`(
IN iattributes_set_title varchar(255)
)
BEGIN


Declare tuserStatusIdDeleted int(11);
declare tcond text;

SELECT statusid into tuserStatusIdDeleted FROM apmmasterrecordsstate  where recordstate='Deleted';

set tcond = '';

if iattributes_set_title <> '' then

  set tcond = concat(tcond," and  ats.attributes_set_title like '%", iattributes_set_title , "%'");

end if;


  set @tstatement=concat("select count(ats.attributes_set_id) as tattributesetscount from store_products_attributes_sets ats, apmmasterrecordsstate b
  where ats.statusid !=", tuserStatusIdDeleted," and ats.statusid = b.statusid  ", tcond);



PREPARE stmt_name FROM @tstatement;
EXECUTE stmt_name;


END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `SPattributesetsdetails`(
IN iattributes_set_id int(11)
)
BEGIN

set @tstatement=concat("SELECT * FROM store_products_attributes_sets  where attributes_set_id = ", iattributes_set_id);
-- select @tstatement;

PREPARE stmt_name FROM @tstatement;
EXECUTE stmt_name;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `SPattributesetsedit`(
IN iattributes_set_id int(11),
IN iattributes_group_id int(11),
IN iattributes_set_title varchar(255),
IN iattribute_ids_string varchar(10000),
IN iaction varchar(255),
IN iadmin int(11)
)
BEGIN

Declare tuserStatusIdActive int(11);
Declare tuserStatusIdDeleted int(11);
Declare trowcount int(11);
Declare tactiondesc varchar(255);
Declare taactivityid int(11);
Declare tcuruseraction varchar(255);
Declare tmess varchar(255);
Declare tstatus int(11);


SELECT statusid into tuserStatusIdActive FROM apmmasterrecordsstate  where recordstate='Active';
SELECT statusid into tuserStatusIdDeleted FROM apmmasterrecordsstate  where recordstate='Deleted';


select statusid into tstatus from store_products_attributes_sets where attributes_set_id = iattributes_set_id;
if tstatus <> tuserStatusIdDeleted then

      update store_products_attributes_sets set
      attributes_set_title         = iattributes_set_title,
      attributes_group_id         = iattributes_group_id
      where attributes_set_id      = iattributes_set_id;

      /*
      delete from store_products_attributes_sets_mapping where attributes_set_id = iattributes_set_id;



            SELECT LENGTH(iattribute_ids_string) - LENGTH(REPLACE(iattribute_ids_string, '#', '')) into @iattributes_id;
            WHILE @iattributes_id > 0 DO

                select sfSPLIT_STR(iattribute_ids_string,'#',@iattributes_id) into @iattributes_id_in;

                insert into store_products_attributes_sets_mapping
                (attribute_id, attributes_set_id, createddatetime, statusid)
                values(@iattributes_id_in,iattributes_set_id,NOW(),tUserStatusIdActive);

                SET @iattributes_id = @iattributes_id - 1;
            END WHILE;
            */

      set tcuruseraction = 'Edit attributesets';
      set tactiondesc = concat('Details were updated for attributes_set_id ',iattributes_set_id, ' by ', iadmin);



      select FNapmwriteactivitylog(iadmin , tcuruseraction, iaction , tactiondesc) into taactivityid;
      set tmess = '1#success';
      select tmess;

else
  set tmess = '2#failure';
  select tmess;
end if;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `SPattributesetslist`(
IN iattributes_set_title varchar(255),
IN istart int(11),
IN ilimit int(11)
)
BEGIN


Declare tuserStatusIdActive int(11);
Declare tuserStatusIdDeleted int(11);
declare tcond text;

SELECT statusid into tuserStatusIdActive FROM apmmasterrecordsstate  where recordstate='Active';
SELECT statusid into tuserStatusIdDeleted FROM apmmasterrecordsstate  where recordstate='Deleted';


set tcond = '';

if iattributes_set_title <> '' then

  set tcond = concat(tcond," and  ats.attributes_set_title like '%", iattributes_set_title , "%'");

end if;



set @tstatement=concat("select * from
store_products_attributes_sets ats, store_products_attributes_groups atg, apmmasterrecordsstate b

where
ats.statusid !=", tuserStatusIdDeleted," and ats.statusid = b.statusid
and ats.attributes_group_id = atg.attributes_group_id order by atg.attributes_group_title, ats.attributes_set_title ");


-- select @tstatement;

PREPARE stmt_name FROM @tstatement;
EXECUTE stmt_name;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `SPattributesetslistactive`()
BEGIN


Declare tuserStatusIdActive int(11);

declare tcond text;

SELECT statusid into tuserStatusIdActive FROM apmmasterrecordsstate  where recordstate='Active';



set @tstatement=concat("select * from store_products_attributes a
where
a.statusid =", tuserStatusIdActive," order by a.attribute_title ");


-- select @tstatement;

PREPARE stmt_name FROM @tstatement;
EXECUTE stmt_name;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `SPattributesetsmappingList`(
IN iattributes_set_id int(11)
)
BEGIN


Declare tuserStatusIdActive int(11);

declare tcond text;

SELECT statusid into tuserStatusIdActive FROM apmmasterrecordsstate  where recordstate='Active';


set @tstatement=concat("SELECT attribute_id FROM store_products_attributes_sets_mapping asm
where
asm.statusid =", tuserStatusIdActive," AND attributes_set_id=", iattributes_set_id, " order by asm.attributes_sets_mapping_id ");


-- select @tstatement;

PREPARE stmt_name FROM @tstatement;
EXECUTE stmt_name;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `SPattributestesadd`(
IN iattributes_group_id int(11),
IN iattributes_set_title varchar(255),
IN iattributes_ids varchar(10000),
IN iaction varchar(255),
IN iadmin int(11)
)
BEGIN


declare tcountcheck int(11) default 0;
declare tcuruseraction varchar(255);
declare tactiondesc varchar(255);
declare tattributesetscount int(5) default 0;
declare tsuccess int(11);
declare tcount int(11);
declare tattributes_set_id int(11);
declare tUserStatusIdActive int(11);
declare taactivityid int(11);
declare toutput varchar(255);



set tcuruseraction = 'Add Attributesets';
set tactiondesc = '';


SELECT statusid into tUserStatusIdActive FROM apmmasterrecordsstate  where recordstate='Active';



select count(attributes_set_id) into tattributesetscount from store_products_attributes_sets
where attributes_set_title = iattributes_set_title;

if tattributesetscount <> 0 then
    set tactiondesc = concat('Unable to create attributesets with ', iattributes_set_title , ' as the attributesets title already exists.');
    set toutput = '0#Failed to register attributesets';

else


			insert into store_products_attributes_sets
			(attributes_set_title,
      attributes_group_id,
			createddatetime,
			statusid)
			values
			(
			iattributes_set_title,
      iattributes_group_id,
			NOW(),
			tUserStatusIdActive);

      select LAST_INSERT_ID() into tattributes_set_id;

                       /*
                       SELECT LENGTH(iattributes_ids) - LENGTH(REPLACE(iattributes_ids, '#', '')) into @iattributes_id;
                       WHILE @iattributes_id > 0 DO

										      select sfSPLIT_STR(iattributes_ids,'#',@iattributes_id) into @iattributes_id_in;

                          insert into store_products_attributes_sets_mapping
                          (attribute_id, attributes_set_id, createddatetime, statusid)
                          values(@iattributes_id_in,tattributes_set_id,NOW(),tUserStatusIdActive);

											    SET @iattributes_id = @iattributes_id - 1;
										   END WHILE;
                       */


      set tactiondesc = concat('Attributesets created with title ', iattributes_set_title, ' and attributes_set_id ', tattributes_set_id , ' by admin ', iadmin);
      set toutput = concat('1#',tattributes_set_id,'#', iattributes_set_title, '#Attriburesets Registered successfully');



end if;


      select FNapmwriteactivitylog(iadmin , tcuruseraction, iaction , tactiondesc) into taactivityid;

  
select toutput;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `SPcategoryadd`(
IN iparent_category_id varchar(255),
IN icategory_name varchar(255),
IN icategory_meta_title varchar(255),
IN icategory_meta_description varchar(255),
IN iaction varchar(255),
IN iadmin int(11)
)
BEGIN


declare tcountcheck int(11) default 0;
declare tcuruseraction varchar(255);
declare tactiondesc varchar(255);
declare tcategorycount int(5) default 0;
declare tsuccess int(11);
declare tcount int(11);
declare tcategoryid int(11);
declare tUserStatusIdActive int(11);
declare taactivityid int(11);
declare toutput varchar(255);



set tcuruseraction = 'Add Category';
set tactiondesc = '';


SELECT statusid into tUserStatusIdActive FROM apmmasterrecordsstate  where recordstate='Active';



select count(category_id) into tcategorycount from store_categories where category_name = icategory_name and parent_category_id = iparent_category_id;

if tcategorycount <> 0 then
    set tactiondesc = concat('Unable to create category with ', icategory_name , ' as the category title already exists.');
    set toutput = '0#Failed to register category';

else


			insert into store_categories
			(parent_category_id,
			category_name,
			category_meta_title,
			category_meta_description,
			createddatetime,
			statusid)
			values
			(
			iparent_category_id,
			icategory_name,
			icategory_meta_title,
			icategory_meta_description,
			NOW(),
			tUserStatusIdActive);

      select LAST_INSERT_ID() into tcategoryid;


      set tactiondesc = concat('Category created with title ', icategory_name, ' and category_id ', tcategoryid , ' by admin ', iadmin);
      set toutput = concat('1#',tcategoryid,'#', icategory_name, '#Category Registered successfully');



end if;


      select FNapmwriteactivitylog(iadmin , tcuruseraction, iaction , tactiondesc) into taactivityid;

  
select toutput;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `SPcategoryaddimage`(
IN icategory_id int(11),
IN icategory_image varchar(255),
IN iaction varchar(255),
IN iadmin int(11)
)
BEGIN



declare tcuruseraction varchar(255);
declare tactiondesc varchar(255);
declare tUserStatusIdActive int(11);
declare taactivityid int(11);
declare toutput varchar(255);
declare tcategory_id int(11);
declare tcategory_name varchar(255);
declare tcategory_image_id int(11);



set tcuruseraction = 'Add Category Image';
set tactiondesc = '';


SELECT statusid into tUserStatusIdActive FROM apmmasterrecordsstate  where recordstate='Active';



select category_id,category_name into tcategory_id, tcategory_name from store_categories where category_id = icategory_id and statusid = tUserStatusIdActive;

if tcategory_id = '' then
    set tactiondesc = concat('Unable to create category image - ', icategory_id , ' category not in active status.');
    set toutput = '0#Failed to create category image';

else


			insert into store_categories_images
			(category_id,
			category_image,
			category_image_title,
			createddatetime,
			statusid)
			values
			(
			icategory_id,
			icategory_image,
			tcategory_name,
			NOW(),
			tUserStatusIdActive);

      select LAST_INSERT_ID() into tcategory_image_id;


      set tactiondesc = concat('Category image created with title ', icategory_image, ' and category_image_id ', tcategory_image_id , ' by admin ', iadmin);
      set toutput = concat('1#',tcategory_image_id,'#', tcategory_name, '#Category image created successfully');



end if;


      select FNapmwriteactivitylog(iadmin , tcuruseraction, iaction , tactiondesc) into taactivityid;

  
select toutput;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `SPcategorychangestatus`(
IN icategory_id int(11),
IN ilockstatus int(1),
IN iunlockstatus int(1),
IN ideletestatus int(1),
IN iaction varchar(255),
IN iadminid int(11),
OUT omess varchar(255)
)
BEGIN


DECLARE tactivestatus int(11);
DECLARE tlockstatus int(11);
DECLARE tdeletestatus int(11);
DECLARE taactivityid int(11);
DECLARE tcategoryaction varchar(255);
DECLARE tactiondesc varchar(255);
DECLARE tcategory_name varchar(255);



SELECT statusid into tactivestatus FROM apmmasterrecordsstate  where recordstate='Active';
SELECT statusid into tlockstatus FROM apmmasterrecordsstate  where recordstate='Locked';
SELECT statusid into tdeletestatus FROM apmmasterrecordsstate  where recordstate='Deleted';

select category_name into tcategory_name from store_categories where category_id = icategory_id;


if ilockstatus = 1 and iunlockstatus = 0 and ideletestatus = 0 then
  set tcategoryaction = 'Lock category';

  update store_categories set statusid = tlockstatus where category_id = icategory_id;

  set tactiondesc = concat('Category with category_id ',icategory_id, ' was Locked by admin with adminid ', iadminid);
  select FNapmwriteactivitylog(iadminid , tcategoryaction, iaction , tactiondesc) into taactivityid;


elseif ilockstatus = 0 and iunlockstatus = 1 and ideletestatus = 0 then

  set tcategoryaction = 'Unlock category';

  update store_categories set statusid = tactivestatus where category_id = icategory_id;

  set tactiondesc = concat('Category with category_id ',icategory_id, ' was Activated by admin with adminid ', iadminid);
  select FNapmwriteactivitylog(iadminid , tcategoryaction, iaction , tactiondesc) into taactivityid;


elseif ilockstatus = 0 and iunlockstatus = 0 and ideletestatus = 1 then

  set tcategoryaction = 'Delete category';

  update store_categories set statusid = tdeletestatus, deleteddatetime = now() where category_id = icategory_id;


  set tactiondesc = concat('Category with category_id ',icategory_id, ' was Deleted by admin with adminid ', iadminid);
  select FNapmwriteactivitylog(iadminid , tcategoryaction, iaction , tactiondesc) into taactivityid;


end if;

  set omess = concat('1#', tcategory_name, '#', '');
  select omess;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `SPcategorycount`(
IN icategory_name varchar(255)
)
BEGIN


Declare tuserStatusIdDeleted int(11);
declare tcond text;

SELECT statusid into tuserStatusIdDeleted FROM apmmasterrecordsstate  where recordstate='Deleted';

set tcond = '';

if icategory_name <> '' then

  set tcond = concat(tcond," and  c.category_name like '%", icategory_name , "%'");

end if;


  set @tstatement=concat("select count(c.category_id) as tcategorycount from store_categories c, apmmasterrecordsstate b
  where c.statusid !=", tuserStatusIdDeleted," and c.statusid = b.statusid  ", tcond);



PREPARE stmt_name FROM @tstatement;
EXECUTE stmt_name;


END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `SPcategorydeleteimage`(
IN icategory_id int(11),
IN icategory_image_id int(11),
IN iaction varchar(255),
IN iadmin int(11)
)
BEGIN



declare tcuruseraction varchar(255);
declare tactiondesc varchar(255);
declare tUserStatusIdActive int(11);
Declare tuserStatusIdDeleted int(11);
declare taactivityid int(11);
declare toutput varchar(255);
declare tcategory_id int(11);
declare tcategory_name varchar(255);
declare tcategory_image_id int(11);



set tcuruseraction = 'Delete Category Image';
set tactiondesc = '';


SELECT statusid into tUserStatusIdActive FROM apmmasterrecordsstate  where recordstate='Active';
SELECT statusid into tuserStatusIdDeleted FROM apmmasterrecordsstate  where recordstate='Deleted';



select category_image_id into tcategory_image_id from store_categories_images where category_image_id = icategory_image_id and statusid = tUserStatusIdActive;

if tcategory_image_id = '' then
    set tactiondesc = concat('Unable to delete category image - ', icategory_image_id , ' category image not in active status.');
    set toutput = '0#Failed to delete category image';

else


		  update store_categories_images set statusid = tuserStatusIdDeleted where category_image_id = icategory_image_id;


      set tactiondesc = concat('Category image deleted ', ' and category_image_id ', tcategory_image_id , ' by admin ', iadmin);
      set toutput = concat('1#',tcategory_image_id,'#', 'Category ID:', icategory_id, '#Category image deleted successfully');



end if;


      select FNapmwriteactivitylog(iadmin , tcuruseraction, iaction , tactiondesc) into taactivityid;

  
select toutput;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `SPcategorydetails`(
IN icategory_id int(11)
)
BEGIN

set @tstatement=concat("SELECT * FROM store_categories  where category_id = ", icategory_id);
-- select @tstatement;

PREPARE stmt_name FROM @tstatement;
EXECUTE stmt_name;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `SPcategorydetailsimages`(
IN icategory_id int(11)
)
BEGIN

Declare tuserStatusIdActive int(11);

SELECT statusid into tUserStatusIdActive FROM apmmasterrecordsstate  where recordstate='Active';

set @tstatement=concat("SELECT * FROM store_categories_images  where category_id = ", icategory_id, ' AND statusid=',tUserStatusIdActive);
-- select @tstatement;

PREPARE stmt_name FROM @tstatement;
EXECUTE stmt_name;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `SPcategoryedit`(
IN icategory_id int(11),
IN iparent_category_id varchar(255),
IN icategory_name varchar(255),
IN icategory_meta_title varchar(255),
IN icategory_meta_description varchar(255),
IN iaction varchar(255),
IN iadmin int(11)
)
BEGIN

Declare tuserStatusIdActive int(11);
Declare tuserStatusIdDeleted int(11);
Declare trowcount int(11);
Declare tactiondesc varchar(255);
Declare taactivityid int(11);
Declare tcuruseraction varchar(255);
Declare tmess varchar(255);
Declare tstatus int(11);


SELECT statusid into tuserStatusIdActive FROM apmmasterrecordsstate  where recordstate='Active';
SELECT statusid into tuserStatusIdDeleted FROM apmmasterrecordsstate  where recordstate='Deleted';


select statusid into tstatus from store_categories where category_id = icategory_id;
if tstatus <> tuserStatusIdDeleted then

      update store_categories set
      parent_category_id         = iparent_category_id,
      category_name              = icategory_name,
      category_meta_title        = icategory_meta_title,
      category_meta_description  = icategory_meta_description
      where category_id          = icategory_id;

      set tcuruseraction = 'Edit category';
      set tactiondesc = concat('Details were updated for category_id ',icategory_id, ' by ', iadmin);



      select FNapmwriteactivitylog(iadmin , tcuruseraction, iaction , tactiondesc) into taactivityid;
      set tmess = '1#success';
      select tmess;

else
  set tmess = '2#failure';
  select tmess;
end if;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `SPcategorylist`(
IN icategory_name varchar(255),
IN istart int(11),
IN ilimit int(11)
)
BEGIN


Declare tuserStatusIdActive int(11);
Declare tuserStatusIdDeleted int(11);
declare tcond text;

SELECT statusid into tuserStatusIdActive FROM apmmasterrecordsstate  where recordstate='Active';
SELECT statusid into tuserStatusIdDeleted FROM apmmasterrecordsstate  where recordstate='Deleted';


set tcond = '';

if icategory_name <> '' then

  set tcond = concat(tcond," and  c.category_name like '%", icategory_name , "%'");

end if;




-- set @tstatement=concat("select *, (select category_name from store_categories where category_id=c.parent_category_id) as parent_category_name from store_categories c, apmmasterrecordsstate b
-- where
-- c.statusid !=", tuserStatusIdDeleted," and c.statusid = b.statusid order by c.category_name limit ", istart,",", ilimit);


set @tstatement=concat("select *, (select category_name from store_categories where category_id=c.parent_category_id) as parent_category_name , (select category_image from store_categories_images where category_id=c.category_id AND statusid=",tuserStatusIdActive,") as category_images from store_categories c, apmmasterrecordsstate b
where
c.statusid !=", tuserStatusIdDeleted," and c.statusid = b.statusid order by c.category_name ");


-- select @tstatement;

PREPARE stmt_name FROM @tstatement;
EXECUTE stmt_name;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `SPcategorylistparent`()
BEGIN


Declare tuserStatusIdActive int(11);
Declare tuserStatusIdDeleted int(11);

SELECT statusid into tuserStatusIdActive FROM apmmasterrecordsstate  where recordstate='Active';
SELECT statusid into tuserStatusIdDeleted FROM apmmasterrecordsstate  where recordstate='Deleted';



set @tstatement=concat("select * from store_categories c, apmmasterrecordsstate b
where
c.statusid !=", tuserStatusIdDeleted," and parent_category_id=0 and c.statusid = b.statusid order by c.category_name");


-- select @tstatement;

PREPARE stmt_name FROM @tstatement;
EXECUTE stmt_name;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `SPcheckapmuserexists`(In iuserid int(11))
BEGIN



SELECT count(userid) as cnt FROM apmusers where userid= iuserid;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `SPgetcountries`()
BEGIN

Declare tmoduleStatusIdActive int(11);

SELECT statusid into tmoduleStatusIdActive FROM apmmasterrecordsstate  where recordstate='Active';


select c.country_id, c.zone_id, c.country_name, c.country_3_code, c.country_2_code, c.country_flag
from com_country c
where
c.statusid=tmoduleStatusIdActive;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `SPmerchantadd`(
IN imerchant_title varchar(255),
IN imerchant_email varchar(255),
IN imerchant_mobile varchar(255),
IN imerchant_phone varchar(255),
IN imerchant_fax varchar(255),
IN imerchant_city varchar(255),
IN imerchant_state varchar(255),
IN imerchant_country int(11),
IN imerchant_address1 varchar(5000),
IN imerchant_address2 varchar(5000),
IN imerchant_postcode varchar(255),
IN imerchant_description varchar(255),
IN iaction varchar(255),
IN iadmin int(11)
)
BEGIN


declare tcountcheck int(11) default 0;
declare tcuruseraction varchar(255);
declare tactiondesc varchar(255);
declare tmerchantcount int(5) default 0;
declare tsuccess int(11);
declare tcount int(11);
declare tmerchantid int(11);
declare tUserStatusIdActive int(11);
declare taactivityid int(11);
declare toutput varchar(255);



set tcuruseraction = 'Add Merchant';
set tactiondesc = '';


SELECT statusid into tUserStatusIdActive FROM apmmasterrecordsstate  where recordstate='Active';



select count(merchant_id) into tmerchantcount from store_merchants where merchant_title = imerchant_title;

if tmerchantcount <> 0 then
    set tactiondesc = concat('Unable to create merchant with ', imerchant_title , ' as the merchant title already exists.');
    set toutput = '0#Failed to register Merchant';

else


			insert into store_merchants
			(merchant_title,
			merchant_email,
			merchant_mobile,
			merchant_phone,
			merchant_fax,
			merchant_city,
			merchant_state,
			merchant_country,
			merchant_address1,
			merchant_address2,
			merchant_postcode,
			merchant_description,
			createddatetime,
			statusid)
			values
			(
			imerchant_title,		
			imerchant_email,
			imerchant_mobile,
			imerchant_phone,
			imerchant_fax,
			imerchant_city,
			imerchant_state,
			imerchant_country,
			imerchant_address1,
			imerchant_address2,
			imerchant_postcode,
			imerchant_description,
			NOW(),
			tUserStatusIdActive);

      select LAST_INSERT_ID() into tmerchantid;


      set tactiondesc = concat('Merchant created with title ', imerchant_title, ' and merchantid ', tmerchantid , ' by admin ', iadmin);
      set toutput = concat('1#', tmerchantid, '#Merchant Registered successfully');



end if;


      select FNapmwriteactivitylog(iadmin , tcuruseraction, iaction , tactiondesc) into taactivityid;

  
select toutput;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `SPmerchantaddimage`(
IN imerchant_id int(11),
IN imerchant_image varchar(255),
IN iaction varchar(255),
IN iadmin int(11)
)
BEGIN



declare tcuruseraction varchar(255);
declare tactiondesc varchar(255);
declare tUserStatusIdActive int(11);
declare taactivityid int(11);
declare toutput varchar(255);
declare tmerchant_id int(11);
declare tmerchant_title varchar(255);
declare tmerchant_image_id int(11);



set tcuruseraction = 'Add Merchant Image';
set tactiondesc = '';


SELECT statusid into tUserStatusIdActive FROM apmmasterrecordsstate  where recordstate='Active';



select merchant_id,merchant_title into tmerchant_id, tmerchant_title from store_merchants where merchant_id = imerchant_id and statusid = tUserStatusIdActive;

if tmerchant_id = '' then
    set tactiondesc = concat('Unable to create merchant image - ', imerchant_id , ' merchant not in active status.');
    set toutput = '0#Failed to create merchant image';

else


			insert into store_merchants_images
			(merchant_id,
			merchant_image,
			merchant_image_title,
			createddatetime,
			statusid)
			values
			(
			imerchant_id,
			imerchant_image,
			tmerchant_title,
			NOW(),
			tUserStatusIdActive);

      select LAST_INSERT_ID() into tmerchant_image_id;


      set tactiondesc = concat('Merchant image created with title ', imerchant_image, ' and merchant_image_id ', tmerchant_image_id , ' by admin ', iadmin);
      set toutput = concat('1#',tmerchant_image_id,'#', tmerchant_title, '#Merchant image created successfully');



end if;


      select FNapmwriteactivitylog(iadmin , tcuruseraction, iaction , tactiondesc) into taactivityid;

  
select toutput;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `SPmerchantchangestatus`(
IN imerchant_id int(11),
IN ilockstatus int(1),
IN iunlockstatus int(1),
IN ideletestatus int(1),
IN iaction varchar(255),
IN iadminid int(11),
OUT omess varchar(255)
)
BEGIN




DECLARE tactivestatus int(11);
DECLARE tlockstatus int(11);
DECLARE tdeletestatus int(11);
DECLARE taactivityid int(11);
DECLARE tuseraction varchar(255);
DECLARE tactiondesc varchar(255);
DECLARE tmerchant_title varchar(255);
DECLARE tmerchant_email varchar(255);


SELECT statusid into tactivestatus FROM apmmasterrecordsstate  where recordstate='Active';
SELECT statusid into tlockstatus FROM apmmasterrecordsstate  where recordstate='Locked';
SELECT statusid into tdeletestatus FROM apmmasterrecordsstate  where recordstate='Deleted';

select merchant_title into tmerchant_title from store_merchants where merchant_id = imerchant_id;
select merchant_email into tmerchant_email from store_merchants where merchant_id = imerchant_id;


if ilockstatus = 1 and iunlockstatus = 0 and ideletestatus = 0 then
  set tuseraction = 'Lock merchant';

  update store_merchants set statusid = tlockstatus where merchant_id = imerchant_id;

  set tactiondesc = concat('Merchant with merchant_id ',imerchant_id, ' was Locked by admin with adminid ', iadminid);
  select FNapmwriteactivitylog(iadminid , tuseraction, iaction , tactiondesc) into taactivityid;


elseif ilockstatus = 0 and iunlockstatus = 1 and ideletestatus = 0 then

  set tuseraction = 'Unlock merchant';

  update store_merchants set statusid = tactivestatus where merchant_id = imerchant_id;

  set tactiondesc = concat('Merchant with merchant_id ',imerchant_id, ' was Activated by admin with adminid ', iadminid);
  select FNapmwriteactivitylog(iadminid , tuseraction, iaction , tactiondesc) into taactivityid;


elseif ilockstatus = 0 and iunlockstatus = 0 and ideletestatus = 1 then

  set tuseraction = 'Delete merchant';

  update store_merchants set statusid = tdeletestatus, deleteddatetime = now() where merchant_id = imerchant_id;


  set tactiondesc = concat('Merchant with merchant_id ',imerchant_id, ' was Deleted by admin with adminid ', iadminid);
  select FNapmwriteactivitylog(iadminid , tuseraction, iaction , tactiondesc) into taactivityid;


end if;

  set omess = concat('1#', tmerchant_title, '#', tmerchant_email);
  select omess;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `SPmerchantdeleteimage`(
IN imerchant_id int(11),
IN imerchant_image_id int(11),
IN iaction varchar(255),
IN iadmin int(11)
)
BEGIN



declare tcuruseraction varchar(255);
declare tactiondesc varchar(255);
declare tUserStatusIdActive int(11);
Declare tuserStatusIdDeleted int(11);
declare taactivityid int(11);
declare toutput varchar(255);
declare tmerchant_id int(11);
declare tmerchant_image_id int(11);



set tcuruseraction = 'Delete Merchant Image';
set tactiondesc = '';


SELECT statusid into tUserStatusIdActive FROM apmmasterrecordsstate  where recordstate='Active';
SELECT statusid into tuserStatusIdDeleted FROM apmmasterrecordsstate  where recordstate='Deleted';



select merchant_image_id into tmerchant_image_id from store_merchants_images where merchant_image_id = imerchant_image_id and statusid = tUserStatusIdActive;

if tmerchant_image_id = '' then
    set tactiondesc = concat('Unable to delete merchant image - ', imerchant_image_id , ' merchant image not in active status.');
    set toutput = '0#Failed to delete merchant image';

else


		  update store_merchants_images set statusid = tuserStatusIdDeleted where merchant_image_id = imerchant_image_id;


      set tactiondesc = concat('Merchant image deleted ', ' and category_image_id ', tmerchant_image_id , ' by admin ', iadmin);
      set toutput = concat('1#',tmerchant_image_id,'#', 'Merchant ID:', imerchant_id, '#Merchant image deleted successfully');



end if;


      select FNapmwriteactivitylog(iadmin , tcuruseraction, iaction , tactiondesc) into taactivityid;

  
select toutput;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `SPmerchantdetails`(
IN imerchant_id int(11)
)
BEGIN

set @tstatement=concat("SELECT * FROM store_merchants where merchant_id = ", imerchant_id);
-- select @tstatement;

PREPARE stmt_name FROM @tstatement;
EXECUTE stmt_name;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `SPmerchantdetailsimages`(
IN imerchant_id int(11)
)
BEGIN

Declare tuserStatusIdActive int(11);

SELECT statusid into tUserStatusIdActive FROM apmmasterrecordsstate  where recordstate='Active';

set @tstatement=concat("SELECT * FROM store_merchants_images  where merchant_id = ", imerchant_id, ' AND statusid=',tUserStatusIdActive);
-- select @tstatement;

PREPARE stmt_name FROM @tstatement;
EXECUTE stmt_name;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `SPmerchantedit`(
IN imerchant_id int(11),
IN imerchant_title varchar(255),
IN imerchant_email varchar(255),
IN imerchant_mobile varchar(255),
IN imerchant_phone varchar(255),
IN imerchant_fax varchar(255),
IN imerchant_city varchar(255),
IN imerchant_state varchar(255),
IN imerchant_country int(11),
IN imerchant_address1 varchar(5000),
IN imerchant_address2 varchar(5000),
IN imerchant_postcode varchar(255),
IN imerchant_description varchar(255),
IN iaction varchar(255),
IN iadmin int(11)
)
BEGIN

Declare tuserStatusIdActive int(11);
Declare tuserStatusIdDeleted int(11);
Declare tappid int(11);
Declare trowcount int(11);
Declare tactiondesc varchar(255);
Declare taactivityid int(11);
Declare tcuruseraction varchar(255);
Declare tmess varchar(255);
Declare tstatus int(11);


SELECT statusid into tuserStatusIdActive FROM apmmasterrecordsstate  where recordstate='Active';
SELECT statusid into tuserStatusIdDeleted FROM apmmasterrecordsstate  where recordstate='Deleted';


select statusid into tstatus from store_merchants where merchant_id = imerchant_id;
if tstatus <> tuserStatusIdDeleted then

      update store_merchants set
      merchant_title        = imerchant_title,
      merchant_email        = imerchant_email,
      merchant_mobile       = imerchant_mobile,
      merchant_phone        = imerchant_phone,
      merchant_fax          = imerchant_fax,
      merchant_city         = imerchant_city,
      merchant_state        = imerchant_state,
      merchant_country      = imerchant_country,
      merchant_address1     = imerchant_address1,
      merchant_address2     = imerchant_address2,
      merchant_postcode     = imerchant_postcode,
      merchant_description    = imerchant_description
      where merchant_id     = imerchant_id;

      set tcuruseraction = 'Edit Merchant';
      set tactiondesc = concat('Details were updated for Merchant Id ',imerchant_id, ' by ', iadmin);



      select FNapmwriteactivitylog(iadmin , tcuruseraction, iaction , tactiondesc) into taactivityid;
      set tmess = '1#success';
      select tmess;

else
  set tmess = '2#failure';
  select tmess;
end if;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `SPmerchantscount`(
IN imerchant_title varchar(255),
IN imerchant_email varchar(255),
IN imerchant_mobile varchar(255)
)
BEGIN


Declare tuserStatusIdDeleted int(11);
declare tcond text;

SELECT statusid into tuserStatusIdDeleted FROM apmmasterrecordsstate  where recordstate='Deleted';

set tcond = '';

if imerchant_title <> '0' then

  set tcond = concat(tcond," and  m.merchant_title like '%", imerchant_title , "%'");

end if;

if imerchant_email <> '0' then

  set tcond = concat(tcond," and m.merchant_email like '%", imerchant_email , "%'");

end if;

if imerchant_mobile <> '0' then

  set tcond = concat(tcond," and m.merchant_mobile like '%", imerchant_mobile , "%'");

end if;




  set @tstatement=concat("select count(m.merchant_id) as tmerchantcount from store_merchants m, apmmasterrecordsstate b
  where m.statusid !=", tuserStatusIdDeleted," and m.statusid = b.statusid  ", tcond);



PREPARE stmt_name FROM @tstatement;
EXECUTE stmt_name;


END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `SPmerchantslist`(
IN istart int(11),
IN ilimit int(11),
IN imerchant_title varchar(255),
IN imerchant_email varchar(255),
IN imerchant_mobile varchar(255)
)
BEGIN


Declare tuserStatusIdActive int(11);
Declare tuserStatusIdDeleted int(11);
declare tcond text;

SELECT statusid into tuserStatusIdActive FROM apmmasterrecordsstate  where recordstate='Active';
SELECT statusid into tuserStatusIdDeleted FROM apmmasterrecordsstate  where recordstate='Deleted';


set tcond = '';

if imerchant_title <> '' then

  set tcond = concat(tcond," and  m.merchant_title like '%", imerchant_title , "%'");

end if;

if imerchant_email <> '' then

  set tcond = concat(tcond," and m.merchant_email like '%", imerchant_email , "%'");

end if;

if imerchant_mobile <> '' then

  set tcond = concat(tcond," and m.merchant_mobile like '%", imerchant_mobile , "%'");

end if;



-- set @tstatement=concat("select * from store_merchants m, apmmasterrecordsstate b
-- where
-- m.statusid !=", tuserStatusIdDeleted," and m.statusid = b.statusid order by m.merchant_title limit ", istart,",", ilimit);

set @tstatement=concat("select m.merchant_id, m.merchant_title, m.merchant_email, m.merchant_mobile, m.merchant_phone, m.merchant_fax, m.merchant_city, m.merchant_state, m.merchant_country, m.merchant_address1, m.merchant_address2, m.merchant_postcode, m.statusid, (select merchant_image from store_merchants_images where merchant_id=m.merchant_id AND statusid=",tuserStatusIdActive,") as merchant_images FROM store_merchants m, apmmasterrecordsstate b
where
m.statusid !=", tuserStatusIdDeleted," and m.statusid = b.statusid order by m.merchant_title  ");


PREPARE stmt_name FROM @tstatement;
EXECUTE stmt_name;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `SPmerchantslistactive`()
BEGIN


Declare tuserStatusIdActive int(11);

declare tcond text;

SELECT statusid into tuserStatusIdActive FROM apmmasterrecordsstate  where recordstate='Active';



set @tstatement=concat("select m.merchant_id, m.merchant_title, m.merchant_email from store_merchants m
where
m.statusid =", tuserStatusIdActive," order by m.merchant_title ");


-- select @tstatement;

PREPARE stmt_name FROM @tstatement;
EXECUTE stmt_name;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `SPproductadd`(
IN iproduct_title varchar(255),
IN iproduct_sku varchar(255),
IN iproduct_meta_title varchar(255),
IN iproduct_meta_description varchar(255),
IN iproduct_small_description varchar(5000),
IN iproduct_description text,
IN iattributes_group_id int(11),
IN iaction varchar(255),
IN iadmin int(11)
)
BEGIN


declare tcountcheck int(11) default 0;
declare tcuruseraction varchar(255);
declare tactiondesc varchar(255);
declare tproductcount int(5) default 0;
declare tsuccess int(11);
declare tcount int(11);
declare tproductid int(11);
declare tUserStatusIdActive int(11);
declare taactivityid int(11);
declare toutput varchar(255);



set tcuruseraction = 'Add Product';
set tactiondesc = '';


SELECT statusid into tUserStatusIdActive FROM apmmasterrecordsstate  where recordstate='Active';



select count(product_id) into tproductcount from store_products where product_title = iproduct_title;

if tproductcount <> 0 then
    set tactiondesc = concat('Unable to create product with ', iproduct_title , ' as the product title already exists.');
    set toutput = '0#Failed to register Product';

else


			insert into store_products
			(product_sku,
			product_title,
			product_small_description,
			product_meta_title,
			product_meta_description,
      attributes_group_id,
			createddatetime,
			statusid)
			values
			(
			iproduct_sku,		
			iproduct_title,
			iproduct_small_description,
			iproduct_meta_title,
			iproduct_meta_description,
      iattributes_group_id,
			NOW(),
			tUserStatusIdActive);

      select LAST_INSERT_ID() into tproductid;

      if tproductid<>'' then
      insert into store_products_description
			(product_description,
			product_id,
			createddatetime,
			statusid)
			values
			(
			iproduct_description,		
			tproductid,
			NOW(),
			tUserStatusIdActive);
      end if;


      set tactiondesc = concat('Procudt created with title ', iproduct_title, ' and product_id ', tproductid , ' by admin ', iadmin);
      set toutput = concat('1#', tproductid, '#Product Registered successfully');



end if;


      select FNapmwriteactivitylog(iadmin , tcuruseraction, iaction , tactiondesc) into taactivityid;

  
select toutput;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `SPproductaddattributevalues`(
IN iproduct_id int(11),
IN iattribute_key_str text,
In iattribute_value_str text,
In iattribute_value_id_str text,
IN iaction varchar(255),
IN iadmin int(11)
)
BEGIN


declare tcountcheck int(11) default 0;
declare tcuruseraction varchar(255);
declare tactiondesc varchar(255);
declare tproductcount int(5) default 0;
declare tproducttitle  varchar(255);
declare tsuccess int(11);
declare tcount int(11);
declare tproductid int(11);
declare tUserStatusIdActive int(11);
declare taactivityid int(11);
declare toutput varchar(255);
declare tattribute_value_id int(11);



set tcuruseraction = 'Add Product Attribute Values';
set tactiondesc = '';


SELECT statusid into tUserStatusIdActive FROM apmmasterrecordsstate  where recordstate='Active';

select product_title into tproducttitle from store_products where product_id = iproduct_id;

select count(product_id) into tproductcount from store_products where product_id = iproduct_id;

if tproductcount = 0 then
    set tactiondesc = concat('Unable to create product attribute values with ', tproducttitle , ' as the product not in active status.');
    set toutput = '0#Failed to add Product prices';

else




            SELECT LENGTH(iattribute_key_str) - LENGTH(REPLACE(iattribute_key_str, '@#@#@', '')) into @iattribute_key_str_count;
            WHILE @iattribute_key_str_count > 0 DO

                select sfSPLIT_STR(iattribute_key_str,'@#@#@',@iattribute_key_str_count) into @iattribute_key_str_in;
                select sfSPLIT_STR(iattribute_value_str,'@#@#@',@iattribute_key_str_count) into @iattribute_value_str_in;
                select sfSPLIT_STR(iattribute_value_id_str,'@#@#@',@iattribute_key_str_count) into @iattribute_value_id_str_in;

                if @iattribute_value_id_str_in <> '' then

                    update store_products_attributes_values set
                    attribute_value = @iattribute_value_str_in
                    where
                    attribute_id = @iattribute_key_str_in
                    AND product_id = iproduct_id
                    AND attribute_value_id = @iattribute_value_id_str_in;

                    set tactiondesc = concat('Product attribute value updated with product_price_id ', @iattribute_value_id_str_in, ' by admin ', iadmin);
                    select FNapmwriteactivitylog(iadmin , tcuruseraction, iaction , tactiondesc) into taactivityid;

                else

                    if @iattribute_key_str_in <> '' AND @iattribute_value_str_in <> '' then
                        insert into store_products_attributes_values (attribute_id, attribute_value, product_id, createddatetime, statusid)
                        values(@iattribute_key_str_in,@iattribute_value_str_in,iproduct_id, NOW(), tUserStatusIdActive);

                        select LAST_INSERT_ID() into tattribute_value_id;

                        set tactiondesc = concat('Product attribute value created with product_price_id', tattribute_value_id , '  by admin ', iadmin);
                        select FNapmwriteactivitylog(iadmin , tcuruseraction, iaction , tactiondesc) into taactivityid;
                    end if;


                end if;


                SET @iattribute_key_str_count = @iattribute_key_str_count - 1;

            END WHILE;

            -- set toutput = 'Success';



end if;


select toutput;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `SPproductaddcategories`(
IN iproduct_id int(11),
IN iproduct_categories varchar(25555),
IN iaction varchar(255),
IN iadmin int(11)
)
BEGIN


declare tcountcheck int(11) default 0;
declare tcuruseraction varchar(255);
declare tactiondesc varchar(255);
declare tproductcount int(5) default 0;
declare tproducttitle  varchar(255);
declare tsuccess int(11);
declare tcount int(11);
declare tproductid int(11);
declare tUserStatusIdActive int(11);
declare taactivityid int(11);
declare toutput varchar(255);
declare tproduct_category_id int(11);



set tcuruseraction = 'Add Product Categories';
set tactiondesc = '';


SELECT statusid into tUserStatusIdActive FROM apmmasterrecordsstate  where recordstate='Active';

select product_title into tproducttitle from store_products where product_id = iproduct_id;

select count(product_id) into tproductcount from store_products where product_id = iproduct_id;

if tproductcount = 0 then
    set tactiondesc = concat('Unable to create product categories with ', tproducttitle , ' as the product not in active status.');
    set toutput = '0#Failed to add Product categories';

else


            delete from store_products_categories where product_id = iproduct_id;

            SELECT LENGTH(iproduct_categories) - LENGTH(REPLACE(iproduct_categories, '#', '')) into @iproduct_categories_count;
            WHILE @iproduct_categories_count > 0 DO

                select sfSPLIT_STR(iproduct_categories,'#',@iproduct_categories_count) into @iproduct_categories_in;



                        insert into store_products_categories (product_id, category_id, createddatetime, statusid)
                        values(iproduct_id,@iproduct_categories_in, NOW(), tUserStatusIdActive);

                        select LAST_INSERT_ID() into tproduct_category_id;

                        set tactiondesc = concat('Product categories created with title ', tproducttitle, ' and product_category_id ', tproduct_category_id , ' by admin ', iadmin);
                        select FNapmwriteactivitylog(iadmin , tcuruseraction, iaction , tactiondesc) into taactivityid;



                SET @iproduct_categories_count = @iproduct_categories_count - 1;

            END WHILE;

            -- set toutput = 'Success';



end if;


select toutput;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `SPproductaddimages`(
IN iproduct_id int(11),
IN iproduct_images varchar(255),
IN iaction varchar(255),
IN iadmin int(11)
)
BEGIN


declare tcountcheck int(11) default 0;
declare tcuruseraction varchar(255);
declare tactiondesc varchar(255);
declare tproductcount int(5) default 0;
declare tproducttitle  varchar(255);
declare tsuccess int(11);
declare tcount int(11);
declare tproductid int(11);
declare tUserStatusIdActive int(11);
declare taactivityid int(11);
declare toutput varchar(255);
declare tproduct_image_id int(11);



set tcuruseraction = 'Add Product Images';
set tactiondesc = '';


SELECT statusid into tUserStatusIdActive FROM apmmasterrecordsstate  where recordstate='Active';

select product_title into tproducttitle from store_products where product_id = iproduct_id;

select count(product_id) into tproductcount from store_products where product_id = iproduct_id;

if tproductcount = 0 then
    set tactiondesc = concat('Unable to create product images with ', tproducttitle , ' as the product not in active status.');
    set toutput = '0#Failed to add Product images';

else




            SELECT LENGTH(iproduct_images) - LENGTH(REPLACE(iproduct_images, '#', '')) into @iproduct_images_count;
            WHILE @iproduct_images_count > 0 DO

                select sfSPLIT_STR(iproduct_images,'#',@iproduct_images_count) into @iproduct_images_in;

                -- select @iproduct_images_in;

                insert into store_products_images
                (product_id, product_image, product_image_title, createddatetime, statusid)
                values(iproduct_id,@iproduct_images_in,tproducttitle,NOW(),tUserStatusIdActive);


                SET @iproduct_images_count = @iproduct_images_count - 1;


                select LAST_INSERT_ID() into tproduct_image_id;
                set tactiondesc = concat('Product image created with title ', tproducttitle, ' and product_image_id ', tproduct_image_id , ' by admin ', iadmin);
                select FNapmwriteactivitylog(iadmin , tcuruseraction, iaction , tactiondesc) into taactivityid;
            END WHILE;

            -- set toutput = 'Success';



end if;





select toutput;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `SPproductaddprices`(
IN iproduct_id int(11),
IN iproduct_price_id varchar(2555),
In iproduct_price_description varchar(2555),
IN iproduct_price varchar(2555),
IN iproduct_discount varchar(2555),
IN iproduct_discount_type varchar(2555),
IN iproduct_stock varchar(2555),
IN idiscount_start_date varchar(2555),
IN idiscount_end_date varchar(2555),
IN iaction varchar(255),
IN iadmin int(11)
)
BEGIN


declare tcountcheck int(11) default 0;
declare tcuruseraction varchar(255);
declare tactiondesc varchar(255);
declare tproductcount int(5) default 0;
declare tproducttitle  varchar(255);
declare tsuccess int(11);
declare tcount int(11);
declare tproductid int(11);
declare tUserStatusIdActive int(11);
declare taactivityid int(11);
declare toutput varchar(255);
declare tproduct_price_id int(11);



set tcuruseraction = 'Add Product Prices';
set tactiondesc = '';


SELECT statusid into tUserStatusIdActive FROM apmmasterrecordsstate  where recordstate='Active';

select product_title into tproducttitle from store_products where product_id = iproduct_id;

select count(product_id) into tproductcount from store_products where product_id = iproduct_id;

if tproductcount = 0 then
    set tactiondesc = concat('Unable to create product prices with ', tproducttitle , ' as the product not in active status.');
    set toutput = '0#Failed to add Product prices';

else




            SELECT LENGTH(iproduct_price) - LENGTH(REPLACE(iproduct_price, '#', '')) into @iproduct_price_count;
            WHILE @iproduct_price_count > 0 DO

                select sfSPLIT_STR(iproduct_price,'#',@iproduct_price_count) into @iproduct_price_in;
                select sfSPLIT_STR(iproduct_price_description,'#',@iproduct_price_count) into @iproduct_price_description_in;
                select sfSPLIT_STR(iproduct_price_id,'#',@iproduct_price_count) into @iproduct_price_id_in;
                select sfSPLIT_STR(iproduct_discount,'#',@iproduct_price_count) into @iproduct_discount_in;
                select sfSPLIT_STR(iproduct_discount_type,'#',@iproduct_price_count) into @iproduct_discount_type_in;
                select sfSPLIT_STR(iproduct_stock,'#',@iproduct_price_count) into @iproduct_stock_in;
                select sfSPLIT_STR(idiscount_start_date,'#',@iproduct_price_count) into @idiscount_start_date_in;
                select sfSPLIT_STR(idiscount_end_date,'#',@iproduct_price_count) into @idiscount_end_date_in;

                if @iproduct_price_id_in <> '' then

                    update store_products_price set
                    product_price_description = @iproduct_price_description_in,
                    product_price = @iproduct_price_in,
                    product_discount = @iproduct_discount_in,
                    product_discount_type = @iproduct_discount_type_in,
                    product_stock = @iproduct_stock_in,
                    discount_start_date = @idiscount_start_date_in,
                    discount_end_date =  @idiscount_end_date_in
                    where product_price_id = @iproduct_price_id_in;

                    set tactiondesc = concat('Product price updated with title ', @iproduct_price_description_in, ' and product_price_id ', @iproduct_price_id_in , ' by admin ', iadmin);
                    select FNapmwriteactivitylog(iadmin , tcuruseraction, iaction , tactiondesc) into taactivityid;

                else

                    if @iproduct_price_in <> '' then
                        insert into store_products_price (product_id, product_price_description, product_price, product_discount, product_discount_type, product_stock, discount_start_date, discount_end_date, createddatetime, statusid)
                        values(iproduct_id,@iproduct_price_description_in,@iproduct_price_in, @iproduct_discount_in, @iproduct_discount_type_in, @iproduct_stock_in, @idiscount_start_date_in, @idiscount_end_date_in, NOW(), tUserStatusIdActive);

                        select LAST_INSERT_ID() into tproduct_price_id;

                        set tactiondesc = concat('Product price created with title ', @iproduct_price_description_in, ' and product_price_id ', tproduct_price_id , ' by admin ', iadmin);
                        select FNapmwriteactivitylog(iadmin , tcuruseraction, iaction , tactiondesc) into taactivityid;
                    end if;

                end if;


                SET @iproduct_price_count = @iproduct_price_count - 1;

            END WHILE;

            -- set toutput = 'Success';



end if;


select toutput;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `SPproductchangestatus`(
IN iproduct_id int(11),
IN ilockstatus int(1),
IN iunlockstatus int(1),
IN ideletestatus int(1),
IN iaction varchar(255),
IN iadminid int(11),
OUT omess varchar(255)
)
BEGIN




DECLARE tactivestatus int(11);
DECLARE tlockstatus int(11);
DECLARE tdeletestatus int(11);
DECLARE taactivityid int(11);
DECLARE tuseraction varchar(255);
DECLARE tactiondesc varchar(255);
DECLARE tproduct_title varchar(255);
-- DECLARE tmerchant_email varchar(255);


SELECT statusid into tactivestatus FROM apmmasterrecordsstate  where recordstate='Active';
SELECT statusid into tlockstatus FROM apmmasterrecordsstate  where recordstate='Locked';
SELECT statusid into tdeletestatus FROM apmmasterrecordsstate  where recordstate='Deleted';

select product_title into tproduct_title from store_products where product_id = iproduct_id;
-- select merchant_email into tmerchant_email from store_merchants where merchant_id = imerchant_id;


if ilockstatus = 1 and iunlockstatus = 0 and ideletestatus = 0 then
  set tuseraction = 'Lock product';

  update store_products set statusid = tlockstatus where product_id = iproduct_id;

  set tactiondesc = concat('Product with product_id ',iproduct_id, ' was Locked by admin with adminid ', iadminid);
  select FNapmwriteactivitylog(iadminid , tuseraction, iaction , tactiondesc) into taactivityid;


elseif ilockstatus = 0 and iunlockstatus = 1 and ideletestatus = 0 then

  set tuseraction = 'Unlock product';

  update store_products set statusid = tactivestatus where product_id = iproduct_id;

  set tactiondesc = concat('Product with product_id ',iproduct_id, ' was Activated by admin with adminid ', iadminid);
  select FNapmwriteactivitylog(iadminid , tuseraction, iaction , tactiondesc) into taactivityid;


elseif ilockstatus = 0 and iunlockstatus = 0 and ideletestatus = 1 then

  set tuseraction = 'Delete product';

  update store_products set statusid = tdeletestatus, deleteddatetime = now() where product_id = iproduct_id;


  set tactiondesc = concat('Product with product_id ',iproduct_id, ' was Deleted by admin with adminid ', iadminid);
  select FNapmwriteactivitylog(iadminid , tuseraction, iaction , tactiondesc) into taactivityid;


end if;

  set omess = concat('1#', tproduct_title);
  select omess;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `SPproducthomepageimage`(
IN iproduct_id int(11),
IN iproduct_imagehome_radio varchar(255),
IN iproduct_imagethumbnail_radio varchar(255),
IN iaction varchar(255),
IN iadmin int(11)
)
BEGIN

declare toutput varchar(255);

  update store_products_images set home_page_image=0, product_thumbnail=0 where product_id = iproduct_id;

  update store_products_images set home_page_image=1 where product_image_id = iproduct_imagehome_radio;

  update store_products_images set product_thumbnail=1 where product_image_id = iproduct_imagethumbnail_radio;

  set toutput = 'Success';

select toutput;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `SPproductimagechangestatus`(
IN iproduct_image_id int(11),
IN ilockstatus int(1),
IN iunlockstatus int(1),
IN ideletestatus int(1),
IN iaction varchar(255),
IN iadminid int(11),
OUT omess varchar(255)
)
BEGIN




DECLARE tactivestatus int(11);
DECLARE tlockstatus int(11);
DECLARE tdeletestatus int(11);
DECLARE taactivityid int(11);
DECLARE tuseraction varchar(255);
DECLARE tactiondesc varchar(255);
DECLARE tproduct_image_title varchar(255);
-- DECLARE tmerchant_email varchar(255);


SELECT statusid into tactivestatus FROM apmmasterrecordsstate  where recordstate='Active';
SELECT statusid into tlockstatus FROM apmmasterrecordsstate  where recordstate='Locked';
SELECT statusid into tdeletestatus FROM apmmasterrecordsstate  where recordstate='Deleted';

select product_image_title into tproduct_image_title from store_products_images where product_image_id = iproduct_image_id;
-- select merchant_email into tmerchant_email from store_merchants where merchant_id = imerchant_id;


if ilockstatus = 1 and iunlockstatus = 0 and ideletestatus = 0 then
  set tuseraction = 'Lock product image';

  update store_products_images set statusid = tlockstatus where product_image_id = iproduct_image_id;

  set tactiondesc = concat('Product image with product_image_id ',iproduct_image_id, ' was Locked by admin with adminid ', iadminid);
  select FNapmwriteactivitylog(iadminid , tuseraction, iaction , tactiondesc) into taactivityid;


elseif ilockstatus = 0 and iunlockstatus = 1 and ideletestatus = 0 then

  set tuseraction = 'Unlock product image';

  update store_products_images set statusid = tactivestatus where product_image_id = iproduct_image_id;

  set tactiondesc = concat('Product image with product_image_id ',iproduct_image_id, ' was Activated by admin with adminid ', iadminid);
  select FNapmwriteactivitylog(iadminid , tuseraction, iaction , tactiondesc) into taactivityid;


elseif ilockstatus = 0 and iunlockstatus = 0 and ideletestatus = 1 then

  set tuseraction = 'Delete product image';

  update store_products_images set statusid = tdeletestatus, deleteddatetime = now() where product_image_id = iproduct_image_id;


  set tactiondesc = concat('Product image with product_image_id ',iproduct_image_id, ' was Deleted by admin with adminid ', iadminid);
  select FNapmwriteactivitylog(iadminid , tuseraction, iaction , tactiondesc) into taactivityid;


end if;

  set omess = concat('1#', tproduct_image_title);
  select omess;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `SPproductscount`(
IN iproduct_title varchar(255)
)
BEGIN


Declare tuserStatusIdDeleted int(11);
declare tcond text;

SELECT statusid into tuserStatusIdDeleted FROM apmmasterrecordsstate  where recordstate='Deleted';

set tcond = '';

if iproduct_title <> '' then

  set tcond = concat(tcond," and  p.product_title like '%", iproduct_title , "%'");

end if;


  set @tstatement=concat("select count(p.product_id) as tproductcount from store_products p, apmmasterrecordsstate b
  where p.statusid !=", tuserStatusIdDeleted," and p.statusid = b.statusid  ", tcond);



PREPARE stmt_name FROM @tstatement;
EXECUTE stmt_name;


END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `SPproductslist`(
IN iproduct_title varchar(255),
IN istart int(11),
IN ilimit int(11)
)
BEGIN


Declare tuserStatusIdActive int(11);
Declare tuserStatusIdDeleted int(11);
declare tcond text;

SELECT statusid into tuserStatusIdActive FROM apmmasterrecordsstate  where recordstate='Active';
SELECT statusid into tuserStatusIdDeleted FROM apmmasterrecordsstate  where recordstate='Deleted';


set tcond = '';

if iproduct_title <> '' then

  set tcond = concat(tcond," and  p.product_title like '%", iproduct_title , "%'");

end if;




set @tstatement=concat("select * from store_products p, apmmasterrecordsstate b
where
p.statusid !=", tuserStatusIdDeleted," and p.statusid = b.statusid ", tcond," order by p.product_title limit ", istart,",", ilimit);




-- select @tstatement;

PREPARE stmt_name FROM @tstatement;
EXECUTE stmt_name;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `SPproductupdate`(
IN iproduct_id varchar(255),
IN iproduct_title varchar(255),
IN iproduct_sku varchar(255),
IN iproduct_meta_title varchar(255),
IN iproduct_meta_description varchar(255),
IN iproduct_small_description varchar(5000),
IN iproduct_description text,
IN iaction varchar(255),
IN iadmin int(11)
)
BEGIN


declare tcountcheck int(11) default 0;
declare tcuruseraction varchar(255);
declare tactiondesc varchar(255);
declare tproduct_id int(5) default 0;
declare tproduct_count int(5) default 0;
declare tsuccess int(11);
declare tcount int(11);
declare tproductid int(11);
declare tUserStatusIdActive int(11);
declare taactivityid int(11);
declare toutput varchar(255);



set tcuruseraction = 'Update Product';
set tactiondesc = '';


SELECT statusid into tUserStatusIdActive FROM apmmasterrecordsstate  where recordstate='Active';



select count(product_id) into tproduct_count from store_products where product_title = iproduct_title AND product_id != iproduct_id;

if tproduct_count > 0 then
    set tactiondesc = concat('Unable to update product with ', iproduct_title , ' as the product title already exists.');
    set toutput = '0#Failed to update Product';

else


			update store_products
			set product_sku = iproduct_sku,
			product_title = iproduct_title,
			product_small_description = iproduct_small_description,
			product_meta_title = iproduct_meta_title,
			product_meta_description = iproduct_meta_description
      where
      product_id = iproduct_id;


      update store_products_description
			set product_description = iproduct_description
			where
      product_id = iproduct_id;


      set tactiondesc = concat('Procudt updated with title ', iproduct_title, ' and product_id ', iproduct_id , ' by admin ', iadmin);
      set toutput = concat('1#', iproduct_id, '#Product Updated successfully');



end if;


      select FNapmwriteactivitylog(iadmin , tcuruseraction, iaction , tactiondesc) into taactivityid;

  
select toutput;

END$$

--
-- Functions
--
CREATE DEFINER=`root`@`localhost` FUNCTION `FNapmsetfirstpassflag`(
iuserid int(11),
iflagvalue INT(11),
isecflag int(11),
isecflagvalue int(11)) RETURNS int(11)
BEGIN



declare tcuruser varchar(255);
declare tUserStatusIdActive int(11);
Declare tUserStatusIdLocked int(11);
Declare tUserStatusIdDeleted int(11);





SELECT SUBSTRING_INDEX(USER(),_utf8'@',1) into tcuruser;


SELECT statusid into tUserStatusIdActive FROM apmmasterrecordsstate  where recordstate='Active';
SELECT statusid into tUserStatusIdLocked FROM apmmasterrecordsstate  where recordstate='Locked';
SELECT statusid into tUserStatusIdDeleted FROM apmmasterrecordsstate  where recordstate='Deleted';







if isecflag = 2 then

  update apmusers set isfirstpass = iflagvalue where userid = iuserid and statusid = tUserStatusIdActive;

  update apmsecurityqa set statusid = tUserStatusIdDeleted, deleteddatetime = now() where userid = iuserid and statusid = tUserStatusIdActive;

  update apmusers set issecured = isecflagvalue where userid = iuserid and statusid = tUserStatusIdActive;

elseif isecflag = 1 then

  update apmusers set issecured = isecflagvalue where userid = iuserid and statusid = tUserStatusIdActive;
  update apmsecurityqa set statusid = tUserStatusIdDeleted, deleteddatetime = now() where userid = iuserid and statusid = tUserStatusIdActive;



elseif isecflag = 0 then

  update apmusers set isfirstpass = iflagvalue
  where userid = iuserid and statusid = tUserStatusIdActive;

end if;

return isecflag;

END$$

CREATE DEFINER=`root`@`localhost` FUNCTION `FNapmwriteactivitylog`(
iuserid int(11),
iuseraction varchar(255),
iactionname varchar(255),
iactiondesc varchar(255)
) RETURNS int(11)
BEGIN


declare tUserStatusIdActive int(11);
declare tactionid int(11);
declare tinserted int(11);
declare tuseractionid int(11);


SELECT statusid into tUserStatusIdActive FROM apmmasterrecordsstate  where recordstate='Active';
select actionid into tactionid from apmmasteractions where actionname = iactionname and statusid =tUserStatusIdActive;

select useractionid into tuseractionid from apmmasteruseractions where useraction = iuseraction and statusid =tUserStatusIdActive;

  insert into apmuseractivitylog(userid, useractionid, actionid, actiondesc, createddatetime,statusid)
         values
         (iuserid, tuseractionid, tactionid, iactiondesc, NOW(),tUserStatusIdActive);

  select LAST_INSERT_ID() into tinserted;

return tinserted;
END$$

CREATE DEFINER=`root`@`localhost` FUNCTION `FNapmwriteuseractivitylog`(
iuserid int(11),
iuseraction varchar(255),
iactionname varchar(255),
icontrollername varchar(255),
imodulename varchar(255),
iactiondesc varchar(255)
) RETURNS int(11)
BEGIN


declare tUserStatusIdActive int(11);
declare tactionid int(11);
declare tinserted int(11);
declare tuseractionid int(11);


SELECT statusid into tUserStatusIdActive FROM apmmasterrecordsstate  where recordstate='Active';

select a.actionid into tactionid from apmmasteractions a, apmmastermodules m, apmmastercontrollers c
where a.actionname = iactionname and a.controllerid = c.controllerid and m.modulename = imodulename
and c.controllername = icontrollername and c.moduleid = m.moduleid and a.statusid =tUserStatusIdActive;

select useractionid into tuseractionid from apmmasteruseractions where useraction = iuseraction and statusid =tUserStatusIdActive;

  insert into apmuseractivitylog(userid, useractionid, actionid, actiondesc, createddatetime,statusid)
         values
         (iuserid, tuseractionid, tactionid, iactiondesc, NOW(),tUserStatusIdActive);

  select LAST_INSERT_ID() into tinserted;

return tinserted;
END$$

CREATE DEFINER=`root`@`localhost` FUNCTION `FNdeleteexpiredsessions`(iTime int(11)) RETURNS int(11)
BEGIN





declare tDeletedCount int(11) default 0;

if iTime is not null
then
DELETE FROM apmsessiondata
            WHERE
                sessexpire < iTime;
select row_count() into tDeletedCount;
end if;
return tDeletedCount;
END$$

CREATE DEFINER=`root`@`localhost` FUNCTION `FNdestroysession`(iSessionId varchar(32)) RETURNS int(11)
BEGIN


declare tRowsEffected int(11) default 0;

if iSessionId is not null
then
DELETE FROM apmsessiondata
            WHERE
                sessid = iSessionId;
select row_count() into tRowsEffected;
end if;
return tRowsEffected;

END$$

CREATE DEFINER=`root`@`localhost` FUNCTION `FNgetactivesessions`() RETURNS int(11)
BEGIN




 
 declare tCount int(11) default 0;

SELECT
                COUNT(sessid) into tCount
            FROM apmsessiondata;
return tCount;
END$$

CREATE DEFINER=`root`@`localhost` FUNCTION `FNreadsessiondata`(iSessionId varchar(32),iTime int(11),iHttpAgent varchar(32)) RETURNS blob
BEGIN

declare tSessionData blob;
SELECT
                sessdata into tSessionData
            FROM
                apmsessiondata
            WHERE
                sessid = iSessionId AND
                sessexpire > iTime AND
                sesshttpuseragent = iHttpAgent limit 1;
return tSessionData;

END$$

CREATE DEFINER=`root`@`localhost` FUNCTION `FNwritesessiondata`(iSessionId varchar(32),iTime int(11),iSessionData blob,iHttpAgent varchar(32)) RETURNS int(11)
BEGIN






 declare tRowsCount int(11) default 0;

 INSERT INTO
                apmsessiondata (
                    sessid,
                    sesshttpuseragent,
                    sessdata,
                    sessexpire,
                    CreatedDateTime
                )
            VALUES (
                iSessionId,
               iHttpAgent,
               iSessionData,
              iTime,
              now()
            )
            ON DUPLICATE KEY UPDATE
                sessdata = iSessionData,
                sessexpire = iTime;
 select row_count() into tRowsCount;
return tRowsCount;
END$$

CREATE DEFINER=`root`@`localhost` FUNCTION `sfSPLIT_STR`(
  x text,
  delim VARCHAR(12),
  pos INT
) RETURNS varchar(255) CHARSET latin1
RETURN REPLACE(SUBSTRING(SUBSTRING_INDEX(x, delim, pos),
       LENGTH(SUBSTRING_INDEX(x, delim, pos -1)) + 1),
       delim, '')$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `apmemailtemplate`
--

CREATE TABLE IF NOT EXISTS `apmemailtemplate` (
  `emailtemplateid` int(11) NOT NULL AUTO_INCREMENT COMMENT 'Email template Id ',
  `emailtemplatename` varchar(255) CHARACTER SET latin1 NOT NULL COMMENT 'Name of the email template',
  `emailcontent` longtext NOT NULL COMMENT 'Content of the email template',
  `emailsubject` varchar(255) NOT NULL COMMENT 'Email subject',
  `emailfrom` varchar(255) NOT NULL COMMENT 'From email id or email ids',
  `createddatetime` datetime NOT NULL COMMENT 'created date time of the record',
  `updateddatetime` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'record updated date time',
  `deleteddatetime` datetime DEFAULT NULL COMMENT 'deleted date time of the record',
  `statusid` int(11) NOT NULL COMMENT 'status of the record',
  `createdby` varchar(255) DEFAULT NULL COMMENT 'Stores MySQL User Created Details',
  `lastupdatedby` varchar(255) DEFAULT NULL COMMENT 'Stores MySQL User last updated Details',
  PRIMARY KEY (`emailtemplateid`),
  KEY `FK_apmemailtemplate_statusid_apmmasterrecordstate` (`statusid`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 COMMENT='emil templates for different actions at reseller level' AUTO_INCREMENT=14 ;

--
-- Dumping data for table `apmemailtemplate`
--

INSERT INTO `apmemailtemplate` (`emailtemplateid`, `emailtemplatename`, `emailcontent`, `emailsubject`, `emailfrom`, `createddatetime`, `updateddatetime`, `deleteddatetime`, `statusid`, `createdby`, `lastupdatedby`) VALUES
(1, 'User Password Mail', '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">\r\n<html xmlns="http://www.w3.org/1999/xhtml"\r\n	xmlns:v="urn:schemas-microsoft-com:vml">\r\n<head>\r\n<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />\r\n<meta name="SKYPE_TOOLBAR" content="SKYPE_TOOLBAR_PARSER_COMPATIBLE" />\r\n<title>GetLinc @ New User Account Temp Password Created</title>\r\n<style type="text/css">\r\nv\\:* {\r\n	behavior: url(#default#VML);\r\n	display: inline-block\r\n}\r\n</style>\r\n</head>\r\n<body>\r\n<table width="594" border="0" cellpadding="0" cellspacing="0">\r\n\r\n\r\n	<tr>\r\n		<td>\r\n		<table width="100%" cellpadding="0" cellspacing="0">\r\n			<tr>\r\n				<td valign="top"\r\n					style="font-size: 12px; color: #000000; line-height: 150%; font-family: Verdana, Geneva, sans-serif;">\r\n\r\n				<table width="596" cellpadding="0" cellspacing="0">\r\n\r\n\r\n					<tr>\r\n						<td valign="top"\r\n							style="font-size: 12px; color: #000000; line-height: 150%; font-family: Verdana, Geneva, sans-serif;">\r\n\r\n						<table width="596" cellpadding="0" cellspacing="0">\r\n\r\n\r\n							<tr>\r\n								\r\n								<td width="596" height="86" align="left"\r\n									style="font-size: 12px; color: #000000;"\r\n									background="#sitebaseurl/public/emailImages/exact-pent-colors-header.jpg">\r\n								\r\n								<table cellpadding="0" cellspacing="0" border="0" width="580">\r\n									<tr>\r\n										<td width="15"></td>										\r\n										<td valign="top"\r\n											style="text-align: left; vertical-align: top;"><img\r\n											align="middle" style="vertical-align: middle;" border="0"\r\n											src="#sitebaseurl/public/emailImages/pent-logo-small1.png"\r\n											alt="GetLinc" /></td>\r\n										<td width="70"></td>\r\n										<td width="15"></td>\r\n									</tr>\r\n								</table>\r\n\r\n\r\n								</td>\r\n							</tr>\r\n\r\n						</table>\r\n						</td>\r\n					</tr>\r\n\r\n				</table>\r\n				</td>\r\n			</tr>\r\n\r\n\r\n\r\n			<!--body -->\r\n\r\n			<tr>\r\n				<td>\r\n				<table width="596" border="0" cellpadding="0" cellspacing="0">\r\n					<tr>						\r\n						<td width="1" bgcolor="#b1b1b1"></td>\r\n						<td>\r\n						<table width="594" align="center" border="0" cellspacing="0">\r\n\r\n							<tr>\r\n								<td style="height: 5px;"></td>\r\n							</tr>\r\n							<tr>\r\n								<td height="20"\r\n									style="text-align: center; font-size: 15px; font-family: Arial, Helvetica, sans-serif;"\r\n									align="center"><strong>GetLinc</strong></td>\r\n							</tr>\r\n							<tr>\r\n								<td height="20"\r\n									style="text-align: center; font-size: 15px; font-family: Arial, Helvetica, sans-serif; border-bottom-color: #cdcdcd; border-bottom-style: solid; border-bottom-width: 2px;"\r\n									align="center"><strong>New User Account -\r\n								Temporary Password</strong></td>\r\n							</tr>\r\n\r\n							<tr>\r\n\r\n								<td bgcolor="#FFFFFF" valign="top" width="595"\r\n									style="font-size: 13px; font-weight: normal; color: #575757; font-family: arial; line-height: 150%;">\r\n								<table width="590" cellpadding="0" cellspacing="0">\r\n\r\n									<tr>\r\n										<td width="15" height="2"></td>\r\n										<td></td>\r\n									</tr>\r\n									<tr>\r\n										<td width="15" height="5"></td>\r\n										<td\r\n											style="color: #575757; font-family: Arial, Helvetica, sans-serif; font-size: 13px;">#date</td>\r\n									</tr>\r\n									<tr>\r\n										<td height="10"></td>\r\n									</tr>\r\n\r\n									<tr>\r\n										<td width="15" height="5"></td>\r\n										<td\r\n											style="font-family: Arial, Helvetica, sans-serif; font-size: 13px; color: #575757">Reference:\r\n										<em>#firstname #lastname </em></td>\r\n										<!--color:#2ca3f5; -->\r\n									</tr>\r\n									<tr>\r\n										<td height="8"></td>\r\n									</tr>\r\n\r\n									<tr>\r\n										<td width="15" height="5"></td>\r\n										<td\r\n											style="color: #575757; font-family: Arial, Helvetica, sans-serif; font-size: 13px; padding-top: 5px;"><b>Welcome!</b>\r\n										An Account has been created for you to access the Portal.</td>\r\n									</tr>\r\n\r\n									<tr>\r\n										<td width="15" height="5"></td>\r\n										<td\r\n											style="color: #575757; font-family: Arial, Helvetica, sans-serif; font-size: 13px; padding-top: 0px;">Details\r\n										of your account and access information are listed below.</td>\r\n									</tr>\r\n\r\n\r\n\r\n									<tr>\r\n										<td height="8"></td>\r\n									</tr>\r\n									<tr>\r\n										<td width="15" height="5"></td>\r\n										<td\r\n											style="color: #575757; font-family: Arial, Helvetica, sans-serif; font-size: 13px; padding-top: 5px;">\r\n										Please contact your System Administrator with any questions.</td>\r\n									</tr>\r\n\r\n									<tr>\r\n										<td height="8"></td>\r\n									</tr>\r\n\r\n								</table>\r\n								</td>\r\n\r\n							</tr>\r\n\r\n							<tr>\r\n								\r\n								<td align="left" valign="middle"\r\n									style="border-top: #666 1px solid; border-bottom: #666 1px solid; font-size: 12px; color: #575757; font-family: Arial, Helvetica, sans-serif;">\r\n								<table width="500" cellpadding="0" cellspacing="0" border="0">\r\n\r\n\r\n									<tr>\r\n										<td width="15" height="5"></td>\r\n										<td height="25"\r\n											style="color: #575757; font-family: Arial, Helvetica, sans-serif; font-size: 13px;">\r\n\r\n										\r\n										<b>Account Information: </b></td>\r\n									</tr>\r\n\r\n\r\n									<tr>\r\n										<td width="15" height="5"></td>\r\n										<td height="20"\r\n											style="color: #575757; font-family: Arial, Helvetica, sans-serif; font-size: 13px;">\r\n										\r\n										First Name: #firstname</td>\r\n									</tr>\r\n\r\n									<tr>\r\n										<td width="15" height="5"></td>\r\n										<td height="20"\r\n											style="color: #575757; font-family: Arial, Helvetica, sans-serif; font-size: 13px;">Last\r\n										Name: #lastname</td>\r\n									</tr>\r\n\r\n									<tr>\r\n										<td width="15" height="5"></td>\r\n										<td height="20"\r\n											style="color: #575757; font-family: Arial, Helvetica, sans-serif; font-size: 13px;">Role:\r\n										#rolename</td>\r\n									</tr>\r\n\r\n								</table>\r\n\r\n								<table width="500" cellpadding="0" cellspacing="0" border="0">\r\n\r\n\r\n									<tr>\r\n										<td width="15" height="5"></td>\r\n										<td height="25"\r\n											style="color: #575757; font-family: Arial, Helvetica, sans-serif; font-size: 13px;">\r\n\r\n										\r\n										<b>Access Information:</b></td>\r\n									</tr>\r\n\r\n\r\n									<tr>\r\n										<td width="15" height="5"></td>\r\n										<td height="20"\r\n											style="color: #575757; font-family: Arial, Helvetica, sans-serif; font-size: 13px;">\r\n										\r\n										Temporary Password: #password</td>\r\n									</tr>\r\n\r\n									<tr>\r\n										<td width="15" height="5"></td>\r\n										<td height="30"\r\n											style="color: #575757; font-family: Arial, Helvetica, sans-serif; font-size: 13px;">\r\n										\r\n										Follow this link to access the Portal: <a\r\n											style="font-family: Arial, Helvetica, sans-serif; font-size: 13px; color: #559bde"\r\n											href="#">#sitebaseurl</a></td>\r\n									</tr>\r\n\r\n								</table>\r\n								</td>\r\n							</tr>\r\n\r\n\r\n\r\n							\r\n						</table>\r\n\r\n						</td>\r\n						<td width="1" bgcolor="#b1b1b1"></td>\r\n					</tr>\r\n					<tr>\r\n						<td width="1" bgcolor="#b1b1b1"></td>\r\n						\r\n						<td style="padding: 0px 10px 0px 10px;" valign="middle"\r\n							align="left" height="47">\r\n						<p\r\n							style="font-size: 11px; font-family: Arial, Helvetica, sans-serif; color: rgb(102, 102, 102); font-weight: normal; margin-top: 5px; margin-bottom: 5px; text-align: justify">Disclaimer:<br>\r\n						The information contained in this electronic message and any\r\n						attachments to this message are intended for the exclusive use of\r\n						the addressee(s) and may contain proprietary, confidential or\r\n						privileged information. If you are not the intended recipient, you\r\n						should not disseminate, distribute or copy this e-mail. Please\r\n						destroy all copies of this message and any attachments. \r\n						</p>\r\n						</td>\r\n						<td width="1" bgcolor="#b1b1b1"></td>\r\n					</tr>\r\n				</table>\r\n				</td>\r\n			</tr>\r\n\r\n\r\n\r\n\r\n\r\n\r\n		</table>\r\n		</td>\r\n	</tr>\r\n\r\n	<tr>\r\n		\r\n		<td width="596" height="70" align="left"\r\n			style="background-repeat: no-repeat; font-size: 12px; color: #000000; font-family: Arial, Helvetica, sans-serif;"\r\n			background="#sitebaseurl/public/emailImages/exact-pent-colors-footer.png">\r\n		\r\n\r\n		<table border="0" cellpadding="0" cellspacing="0" width="580">\r\n			<tr>\r\n				<td width="15" valign="top"></td>\r\n				<td valign="top" width="65"\r\n					style="font-family: Arial, Helvetica, sans-serif; font-size: 10px; font-style: normal; font-weight: normal; color: #fff; padding-left: 35px">This\r\n				document and the information contained therein, is the proprietary\r\n				and confidential information</td>\r\n			</tr>\r\n\r\n			<tr>\r\n				<td></td>\r\n				<td width="80"\r\n					style="font-family: Arial, Helvetica, sans-serif; font-size: 10px; font-style: normal; font-weight: normal; color: #fff; text-align: justify; padding-left: 42px;">of\r\n				GetLinc, Inc. and the document, and the information\r\n				contained therein, may not be</td>\r\n			</tr>\r\n\r\n			<tr>\r\n				<td></td>\r\n				<td width="80"\r\n					style="font-family: Arial, Helvetica, sans-serif; font-size: 10px; font-style: normal; font-weight: normal; color: #fff; padding-left: 44px">used,\r\n				copied, or disclosed without the express prior written consent of\r\n				GetLinc, Inc.</td>\r\n			</tr>\r\n\r\n			<tr>\r\n				<td></td>\r\n				<td width="80"\r\n					style="font-family: Arial, Helvetica, sans-serif; font-size: 10px; font-style: normal; font-weight: bold; color: #fff; padding-left: 135px">&#169\r\n				2013 GetLinc, Inc. All rights reserved.</td>\r\n			</tr>\r\n		</table>\r\n\r\n		</td>\r\n\r\n		\r\n\r\n	</tr>\r\n\r\n</table>\r\n</body>\r\n</html>', 'New User Account - Temporary Password', 'support@getlinc.com', '2012-05-16 07:21:41', '2013-04-05 09:27:54', NULL, 1, NULL, NULL),
(2, 'User Userid Mail', '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">\r\n<html xmlns="http://www.w3.org/1999/xhtml"\r\n	xmlns:v="urn:schemas-microsoft-com:vml">\r\n<head>\r\n<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />\r\n<meta name="SKYPE_TOOLBAR" content="SKYPE_TOOLBAR_PARSER_COMPATIBLE" />\r\n<title>GetLinc @ New User Account Username Created</title>\r\n<style type="text/css">\r\nv\\:* {\r\n	behavior: url(#default#VML);\r\n	display: inline-block\r\n}\r\n</style>\r\n</head>\r\n<body>\r\n<table width="594" border="0" cellpadding="0" cellspacing="0">\r\n\r\n\r\n	<tr>\r\n		<td>\r\n		<table width="100%" cellpadding="0" cellspacing="0">\r\n			<tr>\r\n				<td valign="top"\r\n					style="font-size: 12px; color: #000000; line-height: 150%; font-family: Verdana, Geneva, sans-serif;">\r\n\r\n				<table width="596" cellpadding="0" cellspacing="0">\r\n\r\n\r\n					<tr>\r\n						<td valign="top"\r\n							style="font-size: 12px; color: #000000; line-height: 150%; font-family: Verdana, Geneva, sans-serif;">\r\n\r\n						<table width="596" cellpadding="0" cellspacing="0">\r\n\r\n\r\n							<tr>\r\n								\r\n								<td width="596" height="86" align="left"\r\n									style="font-size: 12px; color: #000000;"\r\n									background="#sitebaseurl/public/emailImages/exact-pent-colors-header.jpg">\r\n								\r\n								<table cellpadding="0" cellspacing="0" border="0" width="580">\r\n									<tr>\r\n										<td width="15"></td>\r\n										\r\n										<td valign="top"\r\n											style="text-align: left; vertical-align: top;"><img\r\n											align="middle" style="vertical-align: middle;" border="0"\r\n											src="#sitebaseurl/public/emailImages/pent-logo-small1.png"\r\n											alt="GetLinc" /></td>\r\n										<td width="70"></td>\r\n										<td width="15"></td>\r\n									</tr>\r\n								</table>\r\n\r\n\r\n								</td>\r\n							</tr>\r\n\r\n						</table>\r\n						</td>\r\n					</tr>\r\n\r\n				</table>\r\n				</td>\r\n			</tr>\r\n\r\n\r\n\r\n			<!--body -->\r\n\r\n			<tr>\r\n				<td>\r\n				<table width="596" border="0" cellpadding="0" cellspacing="0">\r\n					<tr>						\r\n						<td width="1" bgcolor="#b1b1b1"></td>\r\n						<td>\r\n						<table width="594" align="center" border="0" cellspacing="0">\r\n\r\n							<tr>\r\n								<td style="height: 5px;"></td>\r\n							</tr>\r\n							<tr>\r\n								<td height="20"\r\n									style="text-align: center; font-size: 15px; font-family: Arial, Helvetica, sans-serif;"\r\n									align="center"><strong>GetLinc</strong></td>\r\n							</tr>\r\n							<tr>\r\n								<td height="20"\r\n									style="text-align: center; font-size: 15px; font-family: Arial, Helvetica, sans-serif; border-bottom-color: #cdcdcd; border-bottom-style: solid; border-bottom-width: 2px;"\r\n									align="center"><strong>New User Account -\r\n								Username</strong></td>\r\n							</tr>\r\n\r\n							<tr>\r\n\r\n								<td bgcolor="#FFFFFF" valign="top" width="595"\r\n									style="font-size: 13px; font-weight: normal; color: #575757; font-family: arial; line-height: 150%;">\r\n								<table width="590" cellpadding="0" cellspacing="0">\r\n\r\n									<tr>\r\n										<td width="15" height="2"></td>\r\n										<td></td>\r\n									</tr>\r\n									<tr>\r\n										<td width="15" height="5"></td>\r\n										<td\r\n											style="color: #575757; font-family: Arial, Helvetica, sans-serif; font-size: 13px;">#date</td>\r\n									</tr>\r\n									<tr>\r\n										<td height="10"></td>\r\n									</tr>\r\n\r\n									<tr>\r\n										<td width="15" height="5"></td>\r\n										<td\r\n											style="font-family: Arial, Helvetica, sans-serif; font-size: 13px; color: #575757">Reference:\r\n										<em>#firstname #lastname</em></td>\r\n										\r\n									</tr>\r\n									<tr>\r\n										<td height="8"></td>\r\n									</tr>\r\n\r\n									<tr>\r\n										<td width="15" height="5"></td>\r\n										<td\r\n											style="color: #575757; font-family: Arial, Helvetica, sans-serif; font-size: 13px; padding-top: 5px;"><b>Welcome!</b>\r\n										An Account has been created for you to access the Portal.</td>\r\n									</tr>\r\n\r\n									<tr>\r\n										<td width="15" height="5"></td>\r\n										<td\r\n											style="color: #575757; font-family: Arial, Helvetica, sans-serif; font-size: 13px; padding-top: 0px;">Details\r\n										of your account and access information are listed below.</td>\r\n									</tr>\r\n\r\n\r\n\r\n									<tr>\r\n										<td height="8"></td>\r\n									</tr>\r\n									<tr>\r\n										<td width="15" height="5"></td>\r\n										<td\r\n											style="color: #575757; font-family: Arial, Helvetica, sans-serif; font-size: 13px; padding-top: 5px;">\r\n										Please contact your System Administrator with any questions.</td>\r\n									</tr>\r\n\r\n									<tr>\r\n										<td height="8"></td>\r\n									</tr>\r\n\r\n								</table>\r\n								</td>\r\n\r\n							</tr>\r\n\r\n							<tr>\r\n								\r\n								<td align="left" valign="middle"\r\n									style="border-top: #666 1px solid; border-bottom: #666 1px solid; font-size: 12px; color: #575757; font-family: Arial, Helvetica, sans-serif;">\r\n								<table width="500" cellpadding="0" cellspacing="0" border="0">\r\n\r\n\r\n									<tr>\r\n										<td width="15" height="5"></td>\r\n										<td height="25"\r\n											style="color: #575757; font-family: Arial, Helvetica, sans-serif; font-size: 13px;">\r\n\r\n										\r\n										<b>Account Information: </b></td>\r\n									</tr>\r\n\r\n\r\n									<tr>\r\n										<td width="15" height="5"></td>\r\n										<td height="20"\r\n											style="color: #575757; font-family: Arial, Helvetica, sans-serif; font-size: 13px;">\r\n										\r\n										First Name: #firstname</td>\r\n									</tr>\r\n\r\n									<tr>\r\n										<td width="15" height="5"></td>\r\n										<td height="20"\r\n											style="color: #575757; font-family: Arial, Helvetica, sans-serif; font-size: 13px;">Last\r\n										Name: #lastname</td>\r\n									</tr>\r\n\r\n									<tr>\r\n										<td width="15" height="5"></td>\r\n										<td height="20"\r\n											style="color: #575757; font-family: Arial, Helvetica, sans-serif; font-size: 13px;">Role:\r\n										#rolename</td>\r\n									</tr>\r\n\r\n								</table>\r\n\r\n								<table width="500" cellpadding="0" cellspacing="0" border="0">\r\n\r\n\r\n									<tr>\r\n										<td width="15" height="5"></td>\r\n										<td height="25"\r\n											style="color: #575757; font-family: Arial, Helvetica, sans-serif; font-size: 13px;">\r\n\r\n										\r\n										<b>Access Information:</b></td>\r\n									</tr>\r\n\r\n\r\n									<tr>\r\n										<td width="15" height="5"></td>\r\n										<td height="20"\r\n											style="color: #575757; font-family: Arial, Helvetica, sans-serif; font-size: 13px;">\r\n										\r\n										Username: #username</td>\r\n									</tr>\r\n\r\n									<tr>\r\n										<td width="15" height="5"></td>\r\n										<td height="30"\r\n											style="color: #575757; font-family: Arial, Helvetica, sans-serif; font-size: 13px;">\r\n										\r\n										<em>Your temporary password will be sent in a separate\r\n										email. </em></td>\r\n									</tr>\r\n\r\n								</table>\r\n								</td>\r\n							</tr>\r\n\r\n\r\n\r\n							\r\n						</table>\r\n\r\n						</td>\r\n						<td width="1" bgcolor="#b1b1b1"></td>\r\n					</tr>\r\n					<tr>\r\n						<td width="1" bgcolor="#b1b1b1"></td>\r\n\r\n						\r\n						<td style="padding: 0px 10px 0px 10px;" valign="middle"\r\n							align="left" height="47">\r\n						<p\r\n							style="font-size: 11px; font-family: Arial, Helvetica, sans-serif; color: rgb(102, 102, 102); font-weight: normal; margin-top: 5px; margin-bottom: 5px; text-align: justify">Disclaimer:<br>\r\n						The information contained in this electronic message and any\r\n						attachments to this message are intended for the exclusive use of\r\n						the addressee(s) and may contain proprietary, confidential or\r\n						privileged information. If you are not the intended recipient, you\r\n						should not disseminate, distribute or copy this e-mail. Please\r\n						destroy all copies of this message and any attachments. \r\n						</p>\r\n						</td>\r\n						<td width="1" bgcolor="#b1b1b1"></td>\r\n					</tr>\r\n				</table>\r\n				</td>\r\n			</tr>\r\n\r\n\r\n\r\n\r\n\r\n\r\n		</table>\r\n		</td>\r\n	</tr>\r\n\r\n	<tr>\r\n		\r\n		<td width="596" height="70" align="left"\r\n			style="background-repeat: no-repeat; font-size: 12px; color: #000000; font-family: Arial, Helvetica, sans-serif;"\r\n			background="#sitebaseurl/public/emailImages/exact-pent-colors-footer.png">\r\n		\r\n\r\n		<table border="0" cellpadding="0" cellspacing="0" width="580">\r\n			<tr>\r\n				<td width="15" valign="top"></td>\r\n				<td valign="top" width="65"\r\n					style="font-family: Arial, Helvetica, sans-serif; font-size: 10px; font-style: normal; font-weight: normal; color: #fff; padding-left: 35px">This\r\n				document and the information contained therein, is the proprietary\r\n				and confidential information</td>\r\n			</tr>\r\n\r\n			<tr>\r\n				<td></td>\r\n				<td width="80"\r\n					style="font-family: Arial, Helvetica, sans-serif; font-size: 10px; font-style: normal; font-weight: normal; color: #fff; text-align: justify; padding-left: 42px;">of\r\n				GetLinc, Inc. and the document, and the information\r\n				contained therein, may not be</td>\r\n			</tr>\r\n\r\n			<tr>\r\n				<td></td>\r\n				<td width="80"\r\n					style="font-family: Arial, Helvetica, sans-serif; font-size: 10px; font-style: normal; font-weight: normal; color: #fff; padding-left: 44px">used,\r\n				copied, or disclosed without the express prior written consent of\r\n				GetLinc, Inc.</td>\r\n			</tr>\r\n\r\n			<tr>\r\n				<td></td>\r\n				<td width="80"\r\n					style="font-family: Arial, Helvetica, sans-serif; font-size: 10px; font-style: normal; font-weight: bold; color: #fff; padding-left: 135px">&#169\r\n				2013 GetLinc, Inc. All rights reserved.</td>\r\n			</tr>\r\n		</table>\r\n\r\n		</td>\r\n\r\n		\r\n\r\n	</tr>\r\n\r\n</table>\r\n</body>\r\n</html>', 'New User Account - Username', 'support@getlinc.com', '2012-05-16 07:24:17', '2013-04-05 09:27:54', NULL, 1, NULL, NULL),
(3, 'User Locked', '<table width="596" border="0" cellpadding="0" cellspacing="0">\r\n	<tr>\r\n		<td>\r\n		<table width="596" cellpadding="0" cellspacing="0">\r\n			<tr>\r\n				<td valign="top"\r\n					style="font-size: 12px; color: #000000; font-family: Verdana, Geneva, sans-serif;">\r\n\r\n				<table width="596" cellpadding="0" cellspacing="0">\r\n					<tr>\r\n						<td align="left" style="font-size: 12px; color: #000000;"><a\r\n							href="#"><img\r\n							src="%s/public/emailImages/header-MobileFunds-new.png"\r\n							border="0" alt="header"></a></td>\r\n					</tr>\r\n				</table>\r\n				</td>\r\n			</tr>\r\n			<tr>\r\n				<td>\r\n				<table width="596" border="0" cellpadding="0" cellspacing="0">\r\n					<tr>\r\n						<td width="1" bgcolor="#6EB577"></td>\r\n						<td>\r\n						<table width="594" align="center" bgcolor="#fafafa" border="0"\r\n							cellspacing="0">\r\n							<tr>\r\n								<td style="height: 5px;"></td>\r\n							</tr>\r\n							<tr>\r\n								<td\r\n									style="text-align: center; height: 25px; font-size: 15px; font-family: Arial, Helvetica, sans-serif; border-bottom-color: #666; border-bottom-style: dashed; border-bottom-width: 1px;"\r\n									align="center"><b style="color: #575757">Locked User access</b></td>\r\n							</tr>\r\n							<tr>\r\n\r\n								<td bgcolor="#FFFFFF" valign="top" width="570"\r\n									style="font-size: 13px; font-weight: normal; color: #575757; font-family: arial;">\r\n								<table width="510" cellpadding="0" cellspacing="0">\r\n									<tr>\r\n										<td style="height: 10px;">&nbsp;</td>\r\n									</tr>\r\n									<tr>\r\n										<td width="15px" style="height: 5px;"></td>\r\n										<td\r\n											style="color: #075b9b; font-family: Arial, Helvetica, sans-serif; font-size: 14px;">Hi\r\n											%s,</td>\r\n									</tr>\r\n									<tr>\r\n										<td style="height: 10px;">&nbsp;</td>\r\n									</tr>\r\n\r\n									<tr>\r\n										<td width="15px" style="height: 5px;"></td>\r\n										<td\r\n											style="color: #575757; font-family: Arial, Helvetica, sans-serif; font-size: 13px;">Your access has been locked.</td>\r\n									</tr>\r\n									<tr>\r\n										<td style="height: 10px;">&nbsp;</td>\r\n									</tr>\r\n									<tr>\r\n										<td style="height: 10px;">&nbsp;</td>\r\n									</tr>\r\n								</table>\r\n								</td>\r\n							</tr>\r\n							<tr>\r\n								<td style="height: 10px;">&nbsp;</td>\r\n							</tr>\r\n							 \r\n							<tr>\r\n								<td height="15"></td>\r\n							</tr>\r\n							<tr>\r\n								<td bgcolor="#f1f1f1" align="left" valign="middle"\r\n									style="border-bottom: 10px solid #FFFFFF; font-size: 12px; color: #575757; font-family: Arial, Helvetica, sans-serif; padding-left: 30px; padding-right: 30px;">\r\n								<table width="500" cellpadding="0" cellspacing="0" border="0">\r\n									<tr>\r\n										<td align="center" height="30"\r\n											style="color: #575757; font-family: Arial, Helvetica, sans-serif; font-size: 13px;">\r\n\r\n										For further assistance email us at <a\r\n											style="font-family: Arial, Helvetica, sans-serif; font-size: 12px; color: #075b9b"\r\n											href="mailto:customersupport@getlinc.com">support@getlinc.com</a>\r\n\r\n										</td>\r\n									</tr>\r\n									<tr>\r\n										<td align="center" height="30"\r\n											style="color: #575757; font-family: Arial, Helvetica, sans-serif; font-size: 13px;">\r\n										( OR )</td>\r\n									</tr>\r\n									<tr>\r\n										<td align="center" height="30"\r\n											style="color: #575757; font-family: Arial, Helvetica, sans-serif; font-size: 13px;">call\r\n										us at <a style="color: #075b9b"> 9876543211 </a></td>\r\n									</tr>\r\n								</table>\r\n								</td>\r\n							</tr>\r\n						</table>\r\n						</td>\r\n						<td width="1" bgcolor="#6EB577"></td>\r\n					</tr>\r\n					<tr>\r\n						<td width="1" bgcolor="#6EB577"></td>\r\n						<td bgcolor="#fafafa">&nbsp;</td>\r\n						<td width="1" bgcolor="#6EB577"></td>\r\n					</tr>\r\n					<tr>\r\n						<td width="1" bgcolor="#6EB577"></td>\r\n						<td bgcolor="#fafafa" style="font-weight: normal; padding: 0px 10px 0px 10px"\r\n							valign="middle" align="left" height="47">\r\n						<p style="font-size: 11px; font-family: Arial, Helvetica, sans-serif; color: rgb(102, 102, 102); font-weight: normal;">Disclaimer:<br>\r\n						The information contained in this electronic message and any\r\n						attachments to this message are intended for the exclusive use of\r\n						the addressee(s) and may contain proprietary, confidential or\r\n						privileged information. If you are not the intended recipient, you\r\n						should not disseminate, distribute or copy this e-mail. Please\r\n						notify at<a style="font-family: Arial, Helvetica, sans-serif; font-size: 11px; color: #075b9b"\r\n							href="mailto:support@getlinc.com" target="_blank">\r\n						support@getlinc.com</a> immediately and destroy all\r\n						copies of this message and any attachments.</p>\r\n						</td>\r\n						<td width="1" bgcolor="#6EB577"></td>\r\n					</tr>\r\n				</table>\r\n				</td>\r\n			</tr>\r\n		</table>\r\n		</td>\r\n	</tr>\r\n	<tr>\r\n		<td width="596" align="left"\r\n			style="background-repeat: no-repeat; text-align: center; height: 46px; font-size: 12px; color: #000000; font-family: Arial, Helvetica, sans-serif;"><a\r\n			href="mailto:support@getlinc.com"><img\r\n			src="%s/public/emailImages/footer-Mobilefunds-new.jpg"\r\n			width="596" height="46" border="0" style="margin-right: 2px;"\r\n			align="left" /> </a></td>\r\n\r\n	</tr>\r\n</table>', 'Your account has been locked', 'support@getlinc.com', '2012-06-01 09:36:35', '2013-04-05 09:27:54', NULL, 1, NULL, NULL),
(4, 'User Activated', '<table width="596" border="0" cellpadding="0" cellspacing="0">\r\n	<tr>\r\n		<td>\r\n		<table width="596" cellpadding="0" cellspacing="0">\r\n			<tr>\r\n				<td valign="top"\r\n					style="font-size: 12px; color: #000000; font-family: Verdana, Geneva, sans-serif;">\r\n\r\n				<table width="596" cellpadding="0" cellspacing="0">\r\n					<tr>\r\n						<td align="left" style="font-size: 12px; color: #000000;"><a\r\n							href="#"><img\r\n							src="%s/public/emailImages/header-MobileFunds-new.png"\r\n							border="0" alt="header"></a></td>\r\n					</tr>\r\n				</table>\r\n				</td>\r\n			</tr>\r\n			<tr>\r\n				<td>\r\n				<table width="596" border="0" cellpadding="0" cellspacing="0">\r\n					<tr>\r\n						<td width="1" bgcolor="#6EB577"></td>\r\n						<td>\r\n						<table width="594" align="center" bgcolor="#fafafa" border="0"\r\n							cellspacing="0">\r\n							<tr>\r\n								<td style="height: 5px;"></td>\r\n							</tr>\r\n							<tr>\r\n								<td\r\n									style="text-align: center; height: 25px; font-size: 15px; font-family: Arial, Helvetica, sans-serif; border-bottom-color: #666; border-bottom-style: dashed; border-bottom-width: 1px;"\r\n									align="center"><b style="color: #575757">Activated User access</b></td>\r\n							</tr>\r\n							<tr>\r\n\r\n								<td bgcolor="#FFFFFF" valign="top" width="570"\r\n									style="font-size: 13px; font-weight: normal; color: #575757; font-family: arial;">\r\n								<table width="510" cellpadding="0" cellspacing="0">\r\n									<tr>\r\n										<td style="height: 10px;">&nbsp;</td>\r\n									</tr>\r\n									<tr>\r\n										<td width="15px" style="height: 5px;"></td>\r\n										<td\r\n											style="color: #075b9b; font-family: Arial, Helvetica, sans-serif; font-size: 14px;">Hi\r\n											%s,</td>\r\n									</tr>\r\n									<tr>\r\n										<td style="height: 10px;">&nbsp;</td>\r\n									</tr>\r\n\r\n									<tr>\r\n										<td width="15px" style="height: 5px;"></td>\r\n										<td\r\n											style="color: #575757; font-family: Arial, Helvetica, sans-serif; font-size: 13px;">Your access has been Activated.</td>\r\n									</tr>\r\n									<tr>\r\n										<td style="height: 10px;">&nbsp;</td>\r\n									</tr>\r\n									<tr>\r\n										<td style="height: 10px;">&nbsp;</td>\r\n									</tr>\r\n								</table>\r\n								</td>\r\n							</tr>\r\n							<tr>\r\n								<td style="height: 10px;">&nbsp;</td>\r\n							</tr>\r\n							 \r\n							<tr>\r\n								<td height="15"></td>\r\n							</tr>\r\n							<tr>\r\n								<td bgcolor="#f1f1f1" align="left" valign="middle"\r\n									style="border-bottom: 10px solid #FFFFFF; font-size: 12px; color: #575757; font-family: Arial, Helvetica, sans-serif; padding-left: 30px; padding-right: 30px;">\r\n								<table width="500" cellpadding="0" cellspacing="0" border="0">\r\n									<tr>\r\n										<td align="center" height="30"\r\n											style="color: #575757; font-family: Arial, Helvetica, sans-serif; font-size: 13px;">\r\n\r\n										For further assistance email us at <a\r\n											style="font-family: Arial, Helvetica, sans-serif; font-size: 12px; color: #075b9b"\r\n											href="mailto:customersupport@getlinc.com">support@getlinc.com</a>\r\n\r\n										</td>\r\n									</tr>\r\n									<tr>\r\n										<td align="center" height="30"\r\n											style="color: #575757; font-family: Arial, Helvetica, sans-serif; font-size: 13px;">\r\n										( OR )</td>\r\n									</tr>\r\n									<tr>\r\n										<td align="center" height="30"\r\n											style="color: #575757; font-family: Arial, Helvetica, sans-serif; font-size: 13px;">call\r\n										us at <a style="color: #075b9b"> 9876543211 </a></td>\r\n									</tr>\r\n								</table>\r\n								</td>\r\n							</tr>\r\n						</table>\r\n						</td>\r\n						<td width="1" bgcolor="#6EB577"></td>\r\n					</tr>\r\n					<tr>\r\n						<td width="1" bgcolor="#6EB577"></td>\r\n						<td bgcolor="#fafafa">&nbsp;</td>\r\n						<td width="1" bgcolor="#6EB577"></td>\r\n					</tr>\r\n					<tr>\r\n						<td width="1" bgcolor="#6EB577"></td>\r\n						<td bgcolor="#fafafa" style="font-weight: normal; padding: 0px 10px 0px 10px"\r\n							valign="middle" align="left" height="47">\r\n						<p style="font-size: 11px; font-family: Arial, Helvetica, sans-serif; color: rgb(102, 102, 102); font-weight: normal;">Disclaimer:<br>\r\n						The information contained in this electronic message and any\r\n						attachments to this message are intended for the exclusive use of\r\n						the addressee(s) and may contain proprietary, confidential or\r\n						privileged information. If you are not the intended recipient, you\r\n						should not disseminate, distribute or copy this e-mail. Please\r\n						notify at<a style="font-family: Arial, Helvetica, sans-serif; font-size: 11px; color: #075b9b"\r\n							href="mailto:support@getlinc.com" target="_blank">\r\n						support@getlinc.com</a> immediately and destroy all\r\n						copies of this message and any attachments.</p>\r\n						</td>\r\n						<td width="1" bgcolor="#6EB577"></td>\r\n					</tr>\r\n				</table>\r\n				</td>\r\n			</tr>\r\n		</table>\r\n		</td>\r\n	</tr>\r\n	<tr>\r\n		<td width="596" align="left"\r\n			style="background-repeat: no-repeat; text-align: center; height: 46px; font-size: 12px; color: #000000; font-family: Arial, Helvetica, sans-serif;"><a\r\n			href="mailto:support@getlinc.com"><img\r\n			src="%s/public/emailImages/footer-Mobilefunds-new.jpg"\r\n			width="596" height="46" border="0" style="margin-right: 2px;"\r\n			align="left" /> </a></td>\r\n\r\n	</tr>\r\n</table>', 'Your account has been activated', 'support@getlinc.com', '2012-06-01 09:38:51', '2013-04-05 09:27:54', NULL, 1, NULL, NULL),
(5, 'User Deleted', '<table width="596" border="0" cellpadding="0" cellspacing="0">\r\n	<tr>\r\n		<td>\r\n		<table width="596" cellpadding="0" cellspacing="0">\r\n			<tr>\r\n				<td valign="top"\r\n					style="font-size: 12px; color: #000000; font-family: Verdana, Geneva, sans-serif;">\r\n\r\n				<table width="596" cellpadding="0" cellspacing="0">\r\n					<tr>\r\n						<td align="left" style="font-size: 12px; color: #000000;"><a\r\n							href="#"><img\r\n							src="%s/public/emailImages/header-MobileFunds-new.png"\r\n							border="0" alt="header"></a></td>\r\n					</tr>\r\n				</table>\r\n				</td>\r\n			</tr>\r\n			<tr>\r\n				<td>\r\n				<table width="596" border="0" cellpadding="0" cellspacing="0">\r\n					<tr>\r\n						<td width="1" bgcolor="#6EB577"></td>\r\n						<td>\r\n						<table width="594" align="center" bgcolor="#fafafa" border="0"\r\n							cellspacing="0">\r\n							<tr>\r\n								<td style="height: 5px;"></td>\r\n							</tr>\r\n							<tr>\r\n								<td\r\n									style="text-align: center; height: 25px; font-size: 15px; font-family: Arial, Helvetica, sans-serif; border-bottom-color: #666; border-bottom-style: dashed; border-bottom-width: 1px;"\r\n									align="center"><b style="color: #575757">Deleted User</b></td>\r\n							</tr>\r\n							<tr>\r\n\r\n								<td bgcolor="#FFFFFF" valign="top" width="570"\r\n									style="font-size: 13px; font-weight: normal; color: #575757; font-family: arial;">\r\n								<table width="510" cellpadding="0" cellspacing="0">\r\n									<tr>\r\n										<td style="height: 10px;">&nbsp;</td>\r\n									</tr>\r\n									<tr>\r\n										<td width="15px" style="height: 5px;"></td>\r\n										<td\r\n											style="color: #075b9b; font-family: Arial, Helvetica, sans-serif; font-size: 14px;">Hi\r\n											%s,</td>\r\n									</tr>\r\n									<tr>\r\n										<td style="height: 10px;">&nbsp;</td>\r\n									</tr>\r\n\r\n									<tr>\r\n										<td width="15px" style="height: 5px;"></td>\r\n										<td\r\n											style="color: #575757; font-family: Arial, Helvetica, sans-serif; font-size: 13px;">Sorry!, Your access has been Deleted.</td>\r\n									</tr>\r\n									<tr>\r\n										<td style="height: 10px;">&nbsp;</td>\r\n									</tr>\r\n									<tr>\r\n										<td style="height: 10px;">&nbsp;</td>\r\n									</tr>\r\n								</table>\r\n								</td>\r\n							</tr>\r\n							<tr>\r\n								<td style="height: 10px;">&nbsp;</td>\r\n							</tr>\r\n							 \r\n							<tr>\r\n								<td height="15"></td>\r\n							</tr>\r\n							<tr>\r\n								<td bgcolor="#f1f1f1" align="left" valign="middle"\r\n									style="border-bottom: 10px solid #FFFFFF; font-size: 12px; color: #575757; font-family: Arial, Helvetica, sans-serif; padding-left: 30px; padding-right: 30px;">\r\n								<table width="500" cellpadding="0" cellspacing="0" border="0">\r\n									<tr>\r\n										<td align="center" height="30"\r\n											style="color: #575757; font-family: Arial, Helvetica, sans-serif; font-size: 13px;">\r\n\r\n										For further assistance email us at <a\r\n											style="font-family: Arial, Helvetica, sans-serif; font-size: 12px; color: #075b9b"\r\n											href="mailto:customersupport@getlinc.com">support@getlinc.com</a>\r\n\r\n										</td>\r\n									</tr>\r\n									<tr>\r\n										<td align="center" height="30"\r\n											style="color: #575757; font-family: Arial, Helvetica, sans-serif; font-size: 13px;">\r\n										( OR )</td>\r\n									</tr>\r\n									<tr>\r\n										<td align="center" height="30"\r\n											style="color: #575757; font-family: Arial, Helvetica, sans-serif; font-size: 13px;">call\r\n										us at <a style="color: #075b9b"> 9876543211 </a></td>\r\n									</tr>\r\n								</table>\r\n								</td>\r\n							</tr>\r\n						</table>\r\n						</td>\r\n						<td width="1" bgcolor="#6EB577"></td>\r\n					</tr>\r\n					<tr>\r\n						<td width="1" bgcolor="#6EB577"></td>\r\n						<td bgcolor="#fafafa">&nbsp;</td>\r\n						<td width="1" bgcolor="#6EB577"></td>\r\n					</tr>\r\n					<tr>\r\n						<td width="1" bgcolor="#6EB577"></td>\r\n						<td bgcolor="#fafafa" style="font-weight: normal; padding: 0px 10px 0px 10px"\r\n							valign="middle" align="left" height="47">\r\n						<p style="font-size: 11px; font-family: Arial, Helvetica, sans-serif; color: rgb(102, 102, 102); font-weight: normal;">Disclaimer:<br>\r\n						The information contained in this electronic message and any\r\n						attachments to this message are intended for the exclusive use of\r\n						the addressee(s) and may contain proprietary, confidential or\r\n						privileged information. If you are not the intended recipient, you\r\n						should not disseminate, distribute or copy this e-mail. Please\r\n						notify at<a style="font-family: Arial, Helvetica, sans-serif; font-size: 11px; color: #075b9b"\r\n							href="mailto:support@getlinc.com" target="_blank">\r\n						support@getlinc.com</a> immediately and destroy all\r\n						copies of this message and any attachments.</p>\r\n						</td>\r\n						<td width="1" bgcolor="#6EB577"></td>\r\n					</tr>\r\n				</table>\r\n				</td>\r\n			</tr>\r\n		</table>\r\n		</td>\r\n	</tr>\r\n	<tr>\r\n		<td width="596" align="left"\r\n			style="background-repeat: no-repeat; text-align: center; height: 46px; font-size: 12px; color: #000000; font-family: Arial, Helvetica, sans-serif;"><a\r\n			href="mailto:support@getlinc.com"><img\r\n			src="%s/public/emailImages/footer-Mobilefunds-new.jpg"\r\n			width="596" height="46" border="0" style="margin-right: 2px;"\r\n			align="left" /> </a></td>\r\n\r\n	</tr>\r\n</table>', 'Your account has been deleted', 'support@getlinc.com', '2012-06-01 09:41:59', '2013-04-05 09:27:54', NULL, 1, NULL, NULL),
(13, 'User Temp Password Mail', '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">\r\n<html xmlns="http://www.w3.org/1999/xhtml" xmlns:v="urn:schemas-microsoft-com:vml">\r\n<head>\r\n<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />\r\n<meta name="SKYPE_TOOLBAR" content="SKYPE_TOOLBAR_PARSER_COMPATIBLE" />\r\n<title>GetLinc @ New User Account Password Created</title>\r\n<style type="text/css">\r\nv:* { behavior: url(#default#VML); display:inline-block}\r\n</style>\r\n</head>\r\n<body>\r\n<table width="594" border="0" cellpadding="0" cellspacing="0">\r\n\r\n  \r\n  <tr>\r\n    <td>\r\n    <table width="100%" cellpadding="0" cellspacing="0"  >\r\n<tr>\r\n<td valign="top"  style="font-size:12px; color:#000000; line-height:150%; font-family:Verdana, Geneva, sans-serif; ">\r\n\r\n<table width="596" cellpadding="0" cellspacing="0" >\r\n\r\n\r\n<tr>\r\n<td valign="top"  style="font-size:12px; color:#000000; line-height:150%; font-family:Verdana, Geneva, sans-serif; ">\r\n\r\n<table width="596" cellpadding="0" cellspacing="0" >\r\n\r\n\r\n<tr>\r\n\r\n<td background="#sitebaseurl/public/emailImages/exact-pent-colors-header.jpg" width="596"  height="86" align="left"  style=" font-size:12px; color:#000000; "> \r\n	\r\n                          <table cellpadding="0" cellspacing="0" border="0" width="580">\r\n                                          <tr>\r\n                                            <td width="15"> </td>\r\n                                            <td valign="top" style="text-align:left;vertical-align:top;"><img align="middle" style="vertical-align:middle;" border="0" src="#sitebaseurl/public/emailImages/pent-logo-small1.png" alt="GetLinc"/></td>\r\n                                            <td width="70"> </td>\r\n                                            <td width="15"> </td>\r\n                                          </tr>\r\n                                        </table>\r\n                            \r\n</td>\r\n</tr>\r\n\r\n</table></td>\r\n  </tr>\r\n\r\n</table></td>\r\n  </tr>\r\n  \r\n  \r\n  \r\n  <!--body -->\r\n  \r\n  <tr>\r\n    <td>\r\n	<table width="596" border="0"  cellpadding="0" cellspacing="0">\r\n  <tr>\r\n    <td width="1" bgcolor="#b1b1b1"></td>\r\n    <td>\r\n    <table width="594" align="center" border="0" cellspacing="0">\r\n\r\n    <tr><td style="height:5px;"></td></tr>\r\n      <tr>\r\n<td height="20" style="text-align:center; font-size:15px; font-family:Arial, Helvetica, sans-serif;" align="center" ><strong>GetLinc</strong></td>\r\n</tr>\r\n      <tr>\r\n<td height="20" style="text-align:center;font-size:15px; font-family:Arial, Helvetica, sans-serif;border-bottom-color:#cdcdcd;border-bottom-style:solid; border-bottom-width:2px;" align="center" ><strong>User Password Reset </strong></td>\r\n</tr>\r\n\r\n<tr>\r\n\r\n<td bgcolor="#FFFFFF" valign="top" width="595" style="font-size:13px;font-weight:normal;color:#575757;font-family:arial;line-height:150%;">\r\n  <table width="590" cellpadding="0" cellspacing="0">\r\n  \r\n    <tr>\r\n        <td width="15" height="2"> </td>\r\n        <td></td>\r\n      </tr>\r\n    <tr>\r\n    <td width="15" height="5"> </td>\r\n    <td style="color:#575757; font-family:Arial, Helvetica, sans-serif;font-size:13px;">#date</td>\r\n   </tr>\r\n  <tr>\r\n        <td height="10"></td>\r\n      </tr>\r\n\r\n   <tr>\r\n    <td width="15" height="5" ></td>\r\n    <td style=" font-family:Arial, Helvetica, sans-serif;font-size:13px;color:#575757">Reference: <em>#firstname #lastname</em></td>  <!--color:#2ca3f5; -->\r\n   </tr>\r\n      <tr>\r\n        <td height="8"></td>\r\n      </tr>\r\n   \r\n    <tr>\r\n    <td width="15" height="5" ></td>\r\n    <td style="color:#575757; font-family:Arial, Helvetica, sans-serif;font-size:13px;padding-top:5px;"> \r\n      The Password for the User Account referenced above has been successfully reset.  </td>\r\n   </tr>\r\n    \r\n   <tr>\r\n    <td height="8"></td>\r\n    </tr>\r\n    \r\n  </table>\r\n</td>\r\n\r\n</tr>\r\n\r\n<tr>\r\n\r\n<td  align="left" valign="middle" style=" border-top:#666 1px solid;border-bottom:#666 1px solid;font-size:12px; color:#575757; font-family:Arial, Helvetica, sans-serif;">\r\n<table width="500" cellpadding="0" cellspacing="0" border="0">\r\n     \r\n     <tr>\r\n     <td width="15" height="5" ></td>\r\n     <td height="20" style="color:#575757; font-family:Arial, Helvetica, sans-serif;font-size:13px;">Temporary Password: </td></tr>\r\n     \r\n      <tr>\r\n     <td width="15" height="5" ></td>\r\n     <td height="20" style="color:#575757; font-family:Arial, Helvetica, sans-serif;font-size:13px;">#password </td></tr>\r\n     </table>\r\n     </td>\r\n    </tr>\r\n  \r\n    \r\n	  </table>\r\n      \r\n      </td>\r\n    <td width="1" bgcolor="#b1b1b1"></td>\r\n  </tr>\r\n  <tr><td width="1" bgcolor="#b1b1b1"></td>\r\n	\r\n   \r\n    <td style="padding:0px 10px 0px 10px; " valign="middle" align="left" height="47"><p style="font-size:11px;font-family:Arial,Helvetica,sans-serif;color:rgb(102,102,102);font-weight:normal;margin-top:5px; margin-bottom:5px; text-align:justify">Disclaimer:<br>\r\nThe information contained in this electronic message and any attachments to this message are intended for the exclusive use of the addressee(s) and may contain proprietary, confidential or privileged information. If you are not the intended recipient, you should not disseminate, distribute or copy this e-mail. Please destroy all copies of this message and any attachments.\r\n     </p>\r\n     </td><td width="1" bgcolor="#b1b1b1"></td>\r\n  </tr>\r\n</table>	</td>\r\n  </tr>\r\n\r\n\r\n\r\n\r\n\r\n\r\n</table>\r\n</td>\r\n</tr>\r\n\r\n<tr>\r\n\r\n<td  width="596" height="70" align="left" style="background-repeat:no-repeat; font-size:12px; color:#000000; font-family:Arial, Helvetica, sans-serif;" background="#sitebaseurl/public/emailImages/exact-pent-colors-footer.png">\r\n\r\n                            \r\n                            <table border="0" cellpadding="0" cellspacing="0" width="580">\r\n                            <tr>\r\n                            <td width="15" valign="top"></td>\r\n                            <td  valign="top" width="65" style="font-family:Arial, Helvetica, sans-serif;font-size:10px; font-style:normal; font-weight:normal; color:#fff; padding-left:35px" >This document and the information contained therein, is the proprietary and confidential information </td>\r\n                            </tr>\r\n                            \r\n                            <tr>\r\n                            <td ></td>\r\n                            <td width="80" style="font-family:Arial, Helvetica, sans-serif;font-size:10px; font-style:normal; font-weight:normal; color:#fff; text-align:justify; padding-left:42px; " >of GetLinc, Inc. and the document, and the information contained therein, may not be</td>\r\n                            </tr>\r\n                            \r\n                            <tr>\r\n                            <td ></td>\r\n                            <td width="80" style="font-family:Arial, Helvetica, sans-serif;font-size:10px; font-style:normal; font-weight:normal; color:#fff; padding-left:44px" >used, copied, or disclosed without the express prior written consent of GetLinc, Inc.</td>\r\n                            </tr>\r\n                            \r\n                            <tr>\r\n                            <td></td>\r\n                            <td width="80" style="font-family:Arial, Helvetica, sans-serif;font-size:10px; font-style:normal; font-weight:bold; color:#fff; padding-left:135px" >&#169 2011 GetLinc, Inc. All rights reserved.</td>\r\n                            </tr>\r\n                            </table>\r\n                            \r\n                            </td>\r\n\r\n\r\n</tr>\r\n\r\n</table>\r\n</body>\r\n</html>', 'User Password Reset', 'support@getlinc.com', '2012-08-23 14:25:00', '2013-04-05 09:27:54', NULL, 1, NULL, NULL);

-- --------------------------------------------------------

--
-- Table structure for table `apmmailqueue`
--

CREATE TABLE IF NOT EXISTS `apmmailqueue` (
  `mailqueueid` int(11) NOT NULL AUTO_INCREMENT COMMENT 'auto key column for mail queue',
  `emailfrom` varchar(255) NOT NULL COMMENT 'from name or group of names seperated by comma',
  `emailto` varchar(255) NOT NULL COMMENT 'to name or group of names seperated by comma',
  `emailsubject` text NOT NULL COMMENT 'subject line for the mail',
  `body` blob NOT NULL COMMENT 'body content for the mail',
  `mailstatus` int(11) NOT NULL DEFAULT '0' COMMENT 'flag to know whether the email is sent or not, by default it is 0(not sent)',
  `referenceid` bigint(18) DEFAULT NULL,
  `createddatetime` datetime NOT NULL COMMENT 'created date time for this record',
  `updateddatetime` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'record updated date time',
  `deleteddatetime` datetime DEFAULT NULL COMMENT 'deleted date for this record',
  `statusid` int(11) NOT NULL COMMENT 'status of this record and foreign key for recordsstate table',
  `createdby` varchar(255) DEFAULT NULL COMMENT 'Stores MySQL User Created Details',
  `lastupdatedby` varchar(255) DEFAULT NULL COMMENT 'Stores MySQL User last updated Details',
  PRIMARY KEY (`mailqueueid`),
  KEY `FK_apmmailqueue_statusid_apmmasterrecordsstate` (`statusid`),
  KEY `FK_apmmailqueue_mailstatus_apmmastermailstatus` (`mailstatus`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 COMMENT='all mails for the apm portal are saved here' AUTO_INCREMENT=31 ;

--
-- Dumping data for table `apmmailqueue`
--

INSERT INTO `apmmailqueue` (`mailqueueid`, `emailfrom`, `emailto`, `emailsubject`, `body`, `mailstatus`, `referenceid`, `createddatetime`, `updateddatetime`, `deleteddatetime`, `statusid`, `createdby`, `lastupdatedby`) VALUES
(24, 'support@getlinc.com', 'superadmin2@gmail.com', 'New User Account - Username', 0x3c21444f43545950452068746d6c205055424c494320222d2f2f5733432f2f445444205848544d4c20312e30205472616e736974696f6e616c2f2f454e222022687474703a2f2f7777772e77332e6f72672f54522f7868746d6c312f4454442f7868746d6c312d7472616e736974696f6e616c2e647464223e0d0a3c68746d6c20786d6c6e733d22687474703a2f2f7777772e77332e6f72672f313939392f7868746d6c220d0a09786d6c6e733a763d2275726e3a736368656d61732d6d6963726f736f66742d636f6d3a766d6c223e0d0a3c686561643e0d0a3c6d65746120687474702d65717569763d22436f6e74656e742d547970652220636f6e74656e743d22746578742f68746d6c3b20636861727365743d7574662d3822202f3e0d0a3c6d657461206e616d653d22534b5950455f544f4f4c4241522220636f6e74656e743d22534b5950455f544f4f4c4241525f5041525345525f434f4d50415449424c4522202f3e0d0a3c7469746c653e4765744c696e632040204e65772055736572204163636f756e7420557365726e616d6520437265617465643c2f7469746c653e0d0a3c7374796c6520747970653d22746578742f637373223e0d0a763a2a207b0d0a096265686176696f723a2075726c282364656661756c7423564d4c293b0d0a09646973706c61793a20696e6c696e652d626c6f636b0d0a7d0d0a3c2f7374796c653e0d0a3c2f686561643e0d0a3c626f64793e0d0a3c7461626c652077696474683d223539342220626f726465723d2230222063656c6c70616464696e673d2230222063656c6c73706163696e673d2230223e0d0a0d0a0d0a093c74723e0d0a09093c74643e0d0a09093c7461626c652077696474683d2231303025222063656c6c70616464696e673d2230222063656c6c73706163696e673d2230223e0d0a0909093c74723e0d0a090909093c74642076616c69676e3d22746f70220d0a09090909097374796c653d22666f6e742d73697a653a20313270783b20636f6c6f723a20233030303030303b206c696e652d6865696768743a20313530253b20666f6e742d66616d696c793a2056657264616e612c2047656e6576612c2073616e732d73657269663b223e0d0a0d0a090909093c7461626c652077696474683d22353936222063656c6c70616464696e673d2230222063656c6c73706163696e673d2230223e0d0a0d0a0d0a09090909093c74723e0d0a0909090909093c74642076616c69676e3d22746f70220d0a090909090909097374796c653d22666f6e742d73697a653a20313270783b20636f6c6f723a20233030303030303b206c696e652d6865696768743a20313530253b20666f6e742d66616d696c793a2056657264616e612c2047656e6576612c2073616e732d73657269663b223e0d0a0d0a0909090909093c7461626c652077696474683d22353936222063656c6c70616464696e673d2230222063656c6c73706163696e673d2230223e0d0a0d0a0d0a090909090909093c74723e0d0a09090909090909090d0a09090909090909093c74642077696474683d2235393622206865696768743d2238362220616c69676e3d226c656674220d0a0909090909090909097374796c653d22666f6e742d73697a653a20313270783b20636f6c6f723a20233030303030303b220d0a0909090909090909096261636b67726f756e643d2223736974656261736575726c2f7075626c69632f656d61696c496d616765732f65786163742d70656e742d636f6c6f72732d6865616465722e6a7067223e0d0a09090909090909090d0a09090909090909093c7461626c652063656c6c70616464696e673d2230222063656c6c73706163696e673d22302220626f726465723d2230222077696474683d22353830223e0d0a0909090909090909093c74723e0d0a090909090909090909093c74642077696474683d223135223e3c2f74643e0d0a090909090909090909090d0a090909090909090909093c74642076616c69676e3d22746f70220d0a09090909090909090909097374796c653d22746578742d616c69676e3a206c6566743b20766572746963616c2d616c69676e3a20746f703b223e3c696d670d0a0909090909090909090909616c69676e3d226d6964646c6522207374796c653d22766572746963616c2d616c69676e3a206d6964646c653b2220626f726465723d2230220d0a09090909090909090909097372633d2223736974656261736575726c2f7075626c69632f656d61696c496d616765732f70656e742d6c6f676f2d736d616c6c312e706e67220d0a0909090909090909090909616c743d224765744c696e6322202f3e3c2f74643e0d0a090909090909090909093c74642077696474683d223730223e3c2f74643e0d0a090909090909090909093c74642077696474683d223135223e3c2f74643e0d0a0909090909090909093c2f74723e0d0a09090909090909093c2f7461626c653e0d0a0d0a0d0a09090909090909093c2f74643e0d0a090909090909093c2f74723e0d0a0d0a0909090909093c2f7461626c653e0d0a0909090909093c2f74643e0d0a09090909093c2f74723e0d0a0d0a090909093c2f7461626c653e0d0a090909093c2f74643e0d0a0909093c2f74723e0d0a0d0a0d0a0d0a0909093c212d2d626f6479202d2d3e0d0a0d0a0909093c74723e0d0a090909093c74643e0d0a090909093c7461626c652077696474683d223539362220626f726465723d2230222063656c6c70616464696e673d2230222063656c6c73706163696e673d2230223e0d0a09090909093c74723e0909090909090d0a0909090909093c74642077696474683d223122206267636f6c6f723d2223623162316231223e3c2f74643e0d0a0909090909093c74643e0d0a0909090909093c7461626c652077696474683d223539342220616c69676e3d2263656e7465722220626f726465723d2230222063656c6c73706163696e673d2230223e0d0a0d0a090909090909093c74723e0d0a09090909090909093c7464207374796c653d226865696768743a203570783b223e3c2f74643e0d0a090909090909093c2f74723e0d0a090909090909093c74723e0d0a09090909090909093c7464206865696768743d223230220d0a0909090909090909097374796c653d22746578742d616c69676e3a2063656e7465723b20666f6e742d73697a653a20313570783b20666f6e742d66616d696c793a20417269616c2c2048656c7665746963612c2073616e732d73657269663b220d0a090909090909090909616c69676e3d2263656e746572223e3c7374726f6e673e4765744c696e633c2f7374726f6e673e3c2f74643e0d0a090909090909093c2f74723e0d0a090909090909093c74723e0d0a09090909090909093c7464206865696768743d223230220d0a0909090909090909097374796c653d22746578742d616c69676e3a2063656e7465723b20666f6e742d73697a653a20313570783b20666f6e742d66616d696c793a20417269616c2c2048656c7665746963612c2073616e732d73657269663b20626f726465722d626f74746f6d2d636f6c6f723a20236364636463643b20626f726465722d626f74746f6d2d7374796c653a20736f6c69643b20626f726465722d626f74746f6d2d77696474683a203270783b220d0a090909090909090909616c69676e3d2263656e746572223e3c7374726f6e673e4e65772055736572204163636f756e74202d0d0a0909090909090909557365726e616d653c2f7374726f6e673e3c2f74643e0d0a090909090909093c2f74723e0d0a0d0a090909090909093c74723e0d0a0d0a09090909090909093c7464206267636f6c6f723d2223464646464646222076616c69676e3d22746f70222077696474683d22353935220d0a0909090909090909097374796c653d22666f6e742d73697a653a20313370783b20666f6e742d7765696768743a206e6f726d616c3b20636f6c6f723a20233537353735373b20666f6e742d66616d696c793a20617269616c3b206c696e652d6865696768743a20313530253b223e0d0a09090909090909093c7461626c652077696474683d22353930222063656c6c70616464696e673d2230222063656c6c73706163696e673d2230223e0d0a0d0a0909090909090909093c74723e0d0a090909090909090909093c74642077696474683d22313522206865696768743d2232223e3c2f74643e0d0a090909090909090909093c74643e3c2f74643e0d0a0909090909090909093c2f74723e0d0a0909090909090909093c74723e0d0a090909090909090909093c74642077696474683d22313522206865696768743d2235223e3c2f74643e0d0a090909090909090909093c74640d0a09090909090909090909097374796c653d22636f6c6f723a20233537353735373b20666f6e742d66616d696c793a20417269616c2c2048656c7665746963612c2073616e732d73657269663b20666f6e742d73697a653a20313370783b223e4a756e652030322c20323031333c2f74643e0d0a0909090909090909093c2f74723e0d0a0909090909090909093c74723e0d0a090909090909090909093c7464206865696768743d223130223e3c2f74643e0d0a0909090909090909093c2f74723e0d0a0d0a0909090909090909093c74723e0d0a090909090909090909093c74642077696474683d22313522206865696768743d2235223e3c2f74643e0d0a090909090909090909093c74640d0a09090909090909090909097374796c653d22666f6e742d66616d696c793a20417269616c2c2048656c7665746963612c2073616e732d73657269663b20666f6e742d73697a653a20313370783b20636f6c6f723a2023353735373537223e5265666572656e63653a0d0a090909090909090909093c656d3e537570657261646d696e2054776f3c2f656d3e3c2f74643e0d0a090909090909090909090d0a0909090909090909093c2f74723e0d0a0909090909090909093c74723e0d0a090909090909090909093c7464206865696768743d2238223e3c2f74643e0d0a0909090909090909093c2f74723e0d0a0d0a0909090909090909093c74723e0d0a090909090909090909093c74642077696474683d22313522206865696768743d2235223e3c2f74643e0d0a090909090909090909093c74640d0a09090909090909090909097374796c653d22636f6c6f723a20233537353735373b20666f6e742d66616d696c793a20417269616c2c2048656c7665746963612c2073616e732d73657269663b20666f6e742d73697a653a20313370783b2070616464696e672d746f703a203570783b223e3c623e57656c636f6d65213c2f623e0d0a09090909090909090909416e204163636f756e7420686173206265656e206372656174656420666f7220796f7520746f206163636573732074686520506f7274616c2e3c2f74643e0d0a0909090909090909093c2f74723e0d0a0d0a0909090909090909093c74723e0d0a090909090909090909093c74642077696474683d22313522206865696768743d2235223e3c2f74643e0d0a090909090909090909093c74640d0a09090909090909090909097374796c653d22636f6c6f723a20233537353735373b20666f6e742d66616d696c793a20417269616c2c2048656c7665746963612c2073616e732d73657269663b20666f6e742d73697a653a20313370783b2070616464696e672d746f703a203070783b223e44657461696c730d0a090909090909090909096f6620796f7572206163636f756e7420616e642061636365737320696e666f726d6174696f6e20617265206c69737465642062656c6f772e3c2f74643e0d0a0909090909090909093c2f74723e0d0a0d0a0d0a0d0a0909090909090909093c74723e0d0a090909090909090909093c7464206865696768743d2238223e3c2f74643e0d0a0909090909090909093c2f74723e0d0a0909090909090909093c74723e0d0a090909090909090909093c74642077696474683d22313522206865696768743d2235223e3c2f74643e0d0a090909090909090909093c74640d0a09090909090909090909097374796c653d22636f6c6f723a20233537353735373b20666f6e742d66616d696c793a20417269616c2c2048656c7665746963612c2073616e732d73657269663b20666f6e742d73697a653a20313370783b2070616464696e672d746f703a203570783b223e0d0a09090909090909090909506c6561736520636f6e7461637420796f75722053797374656d2041646d696e6973747261746f72207769746820616e79207175657374696f6e732e3c2f74643e0d0a0909090909090909093c2f74723e0d0a0d0a0909090909090909093c74723e0d0a090909090909090909093c7464206865696768743d2238223e3c2f74643e0d0a0909090909090909093c2f74723e0d0a0d0a09090909090909093c2f7461626c653e0d0a09090909090909093c2f74643e0d0a0d0a090909090909093c2f74723e0d0a0d0a090909090909093c74723e0d0a09090909090909090d0a09090909090909093c746420616c69676e3d226c656674222076616c69676e3d226d6964646c65220d0a0909090909090909097374796c653d22626f726465722d746f703a20233636362031707820736f6c69643b20626f726465722d626f74746f6d3a20233636362031707820736f6c69643b20666f6e742d73697a653a20313270783b20636f6c6f723a20233537353735373b20666f6e742d66616d696c793a20417269616c2c2048656c7665746963612c2073616e732d73657269663b223e0d0a09090909090909093c7461626c652077696474683d22353030222063656c6c70616464696e673d2230222063656c6c73706163696e673d22302220626f726465723d2230223e0d0a0d0a0d0a0909090909090909093c74723e0d0a090909090909090909093c74642077696474683d22313522206865696768743d2235223e3c2f74643e0d0a090909090909090909093c7464206865696768743d223235220d0a09090909090909090909097374796c653d22636f6c6f723a20233537353735373b20666f6e742d66616d696c793a20417269616c2c2048656c7665746963612c2073616e732d73657269663b20666f6e742d73697a653a20313370783b223e0d0a0d0a090909090909090909090d0a090909090909090909093c623e4163636f756e7420496e666f726d6174696f6e3a203c2f623e3c2f74643e0d0a0909090909090909093c2f74723e0d0a0d0a0d0a0909090909090909093c74723e0d0a090909090909090909093c74642077696474683d22313522206865696768743d2235223e3c2f74643e0d0a090909090909090909093c7464206865696768743d223230220d0a09090909090909090909097374796c653d22636f6c6f723a20233537353735373b20666f6e742d66616d696c793a20417269616c2c2048656c7665746963612c2073616e732d73657269663b20666f6e742d73697a653a20313370783b223e0d0a090909090909090909090d0a090909090909090909094669727374204e616d653a20537570657261646d696e3c2f74643e0d0a0909090909090909093c2f74723e0d0a0d0a0909090909090909093c74723e0d0a090909090909090909093c74642077696474683d22313522206865696768743d2235223e3c2f74643e0d0a090909090909090909093c7464206865696768743d223230220d0a09090909090909090909097374796c653d22636f6c6f723a20233537353735373b20666f6e742d66616d696c793a20417269616c2c2048656c7665746963612c2073616e732d73657269663b20666f6e742d73697a653a20313370783b223e4c6173740d0a090909090909090909094e616d653a2054776f3c2f74643e0d0a0909090909090909093c2f74723e0d0a0d0a0909090909090909093c74723e0d0a090909090909090909093c74642077696474683d22313522206865696768743d2235223e3c2f74643e0d0a090909090909090909093c7464206865696768743d223230220d0a09090909090909090909097374796c653d22636f6c6f723a20233537353735373b20666f6e742d66616d696c793a20417269616c2c2048656c7665746963612c2073616e732d73657269663b20666f6e742d73697a653a20313370783b223e526f6c653a0d0a09090909090909090909537570657261646d696e3c2f74643e0d0a0909090909090909093c2f74723e0d0a0d0a09090909090909093c2f7461626c653e0d0a0d0a09090909090909093c7461626c652077696474683d22353030222063656c6c70616464696e673d2230222063656c6c73706163696e673d22302220626f726465723d2230223e0d0a0d0a0d0a0909090909090909093c74723e0d0a090909090909090909093c74642077696474683d22313522206865696768743d2235223e3c2f74643e0d0a090909090909090909093c7464206865696768743d223235220d0a09090909090909090909097374796c653d22636f6c6f723a20233537353735373b20666f6e742d66616d696c793a20417269616c2c2048656c7665746963612c2073616e732d73657269663b20666f6e742d73697a653a20313370783b223e0d0a0d0a090909090909090909090d0a090909090909090909093c623e41636365737320496e666f726d6174696f6e3a3c2f623e3c2f74643e0d0a0909090909090909093c2f74723e0d0a0d0a0d0a0909090909090909093c74723e0d0a090909090909090909093c74642077696474683d22313522206865696768743d2235223e3c2f74643e0d0a090909090909090909093c7464206865696768743d223230220d0a09090909090909090909097374796c653d22636f6c6f723a20233537353735373b20666f6e742d66616d696c793a20417269616c2c2048656c7665746963612c2073616e732d73657269663b20666f6e742d73697a653a20313370783b223e0d0a090909090909090909090d0a09090909090909090909557365726e616d653a20737570657261646d696e3240676d61696c2e636f6d3c2f74643e0d0a0909090909090909093c2f74723e0d0a0d0a0909090909090909093c74723e0d0a090909090909090909093c74642077696474683d22313522206865696768743d2235223e3c2f74643e0d0a090909090909090909093c7464206865696768743d223330220d0a09090909090909090909097374796c653d22636f6c6f723a20233537353735373b20666f6e742d66616d696c793a20417269616c2c2048656c7665746963612c2073616e732d73657269663b20666f6e742d73697a653a20313370783b223e0d0a090909090909090909090d0a090909090909090909093c656d3e596f75722074656d706f726172792070617373776f72642077696c6c2062652073656e7420696e20612073657061726174650d0a09090909090909090909656d61696c2e203c2f656d3e3c2f74643e0d0a0909090909090909093c2f74723e0d0a0d0a09090909090909093c2f7461626c653e0d0a09090909090909093c2f74643e0d0a090909090909093c2f74723e0d0a0d0a0d0a0d0a090909090909090d0a0909090909093c2f7461626c653e0d0a0d0a0909090909093c2f74643e0d0a0909090909093c74642077696474683d223122206267636f6c6f723d2223623162316231223e3c2f74643e0d0a09090909093c2f74723e0d0a09090909093c74723e0d0a0909090909093c74642077696474683d223122206267636f6c6f723d2223623162316231223e3c2f74643e0d0a0d0a0909090909090d0a0909090909093c7464207374796c653d2270616464696e673a2030707820313070782030707820313070783b222076616c69676e3d226d6964646c65220d0a09090909090909616c69676e3d226c65667422206865696768743d223437223e0d0a0909090909093c700d0a090909090909097374796c653d22666f6e742d73697a653a20313170783b20666f6e742d66616d696c793a20417269616c2c2048656c7665746963612c2073616e732d73657269663b20636f6c6f723a20726762283130322c203130322c20313032293b20666f6e742d7765696768743a206e6f726d616c3b206d617267696e2d746f703a203570783b206d617267696e2d626f74746f6d3a203570783b20746578742d616c69676e3a206a757374696679223e446973636c61696d65723a3c62723e0d0a09090909090954686520696e666f726d6174696f6e20636f6e7461696e656420696e207468697320656c656374726f6e6963206d65737361676520616e6420616e790d0a0909090909096174746163686d656e747320746f2074686973206d6573736167652061726520696e74656e64656420666f7220746865206578636c757369766520757365206f660d0a0909090909097468652061646472657373656528732920616e64206d617920636f6e7461696e2070726f70726965746172792c20636f6e666964656e7469616c206f720d0a09090909090970726976696c6567656420696e666f726d6174696f6e2e20496620796f7520617265206e6f742074686520696e74656e64656420726563697069656e742c20796f750d0a09090909090973686f756c64206e6f742064697373656d696e6174652c2064697374726962757465206f7220636f7079207468697320652d6d61696c2e20506c656173650d0a09090909090964657374726f7920616c6c20636f70696573206f662074686973206d65737361676520616e6420616e79206174746163686d656e74732e200d0a0909090909093c2f703e0d0a0909090909093c2f74643e0d0a0909090909093c74642077696474683d223122206267636f6c6f723d2223623162316231223e3c2f74643e0d0a09090909093c2f74723e0d0a090909093c2f7461626c653e0d0a090909093c2f74643e0d0a0909093c2f74723e0d0a0d0a0d0a0d0a0d0a0d0a0d0a09093c2f7461626c653e0d0a09093c2f74643e0d0a093c2f74723e0d0a0d0a093c74723e0d0a09090d0a09093c74642077696474683d2235393622206865696768743d2237302220616c69676e3d226c656674220d0a0909097374796c653d226261636b67726f756e642d7265706561743a206e6f2d7265706561743b20666f6e742d73697a653a20313270783b20636f6c6f723a20233030303030303b20666f6e742d66616d696c793a20417269616c2c2048656c7665746963612c2073616e732d73657269663b220d0a0909096261636b67726f756e643d2223736974656261736575726c2f7075626c69632f656d61696c496d616765732f65786163742d70656e742d636f6c6f72732d666f6f7465722e706e67223e0d0a09090d0a0d0a09093c7461626c6520626f726465723d2230222063656c6c70616464696e673d2230222063656c6c73706163696e673d2230222077696474683d22353830223e0d0a0909093c74723e0d0a090909093c74642077696474683d223135222076616c69676e3d22746f70223e3c2f74643e0d0a090909093c74642076616c69676e3d22746f70222077696474683d223635220d0a09090909097374796c653d22666f6e742d66616d696c793a20417269616c2c2048656c7665746963612c2073616e732d73657269663b20666f6e742d73697a653a20313070783b20666f6e742d7374796c653a206e6f726d616c3b20666f6e742d7765696768743a206e6f726d616c3b20636f6c6f723a20236666663b2070616464696e672d6c6566743a2033357078223e546869730d0a09090909646f63756d656e7420616e642074686520696e666f726d6174696f6e20636f6e7461696e6564207468657265696e2c206973207468652070726f70726965746172790d0a09090909616e6420636f6e666964656e7469616c20696e666f726d6174696f6e3c2f74643e0d0a0909093c2f74723e0d0a0d0a0909093c74723e0d0a090909093c74643e3c2f74643e0d0a090909093c74642077696474683d223830220d0a09090909097374796c653d22666f6e742d66616d696c793a20417269616c2c2048656c7665746963612c2073616e732d73657269663b20666f6e742d73697a653a20313070783b20666f6e742d7374796c653a206e6f726d616c3b20666f6e742d7765696768743a206e6f726d616c3b20636f6c6f723a20236666663b20746578742d616c69676e3a206a7573746966793b2070616464696e672d6c6566743a20343270783b223e6f660d0a090909094765744c696e632c20496e632e20616e642074686520646f63756d656e742c20616e642074686520696e666f726d6174696f6e0d0a09090909636f6e7461696e6564207468657265696e2c206d6179206e6f742062653c2f74643e0d0a0909093c2f74723e0d0a0d0a0909093c74723e0d0a090909093c74643e3c2f74643e0d0a090909093c74642077696474683d223830220d0a09090909097374796c653d22666f6e742d66616d696c793a20417269616c2c2048656c7665746963612c2073616e732d73657269663b20666f6e742d73697a653a20313070783b20666f6e742d7374796c653a206e6f726d616c3b20666f6e742d7765696768743a206e6f726d616c3b20636f6c6f723a20236666663b2070616464696e672d6c6566743a2034347078223e757365642c0d0a09090909636f706965642c206f7220646973636c6f73656420776974686f7574207468652065787072657373207072696f72207772697474656e20636f6e73656e74206f660d0a090909094765744c696e632c20496e632e3c2f74643e0d0a0909093c2f74723e0d0a0d0a0909093c74723e0d0a090909093c74643e3c2f74643e0d0a090909093c74642077696474683d223830220d0a09090909097374796c653d22666f6e742d66616d696c793a20417269616c2c2048656c7665746963612c2073616e732d73657269663b20666f6e742d73697a653a20313070783b20666f6e742d7374796c653a206e6f726d616c3b20666f6e742d7765696768743a20626f6c643b20636f6c6f723a20236666663b2070616464696e672d6c6566743a203133357078223e26233136390d0a0909090932303133204765744c696e632c20496e632e20416c6c207269676874732072657365727665642e3c2f74643e0d0a0909093c2f74723e0d0a09093c2f7461626c653e0d0a0d0a09093c2f74643e0d0a0d0a09090d0a0d0a093c2f74723e0d0a0d0a3c2f7461626c653e0d0a3c2f626f64793e0d0a3c2f68746d6c3e, 1, NULL, '2013-06-02 13:55:31', '2013-06-02 08:25:31', NULL, 1, NULL, NULL),
(25, 'support@getlinc.com', 'superadmin2@gmail.com', 'New User Account - Temporary Password', 0x3c21444f43545950452068746d6c205055424c494320222d2f2f5733432f2f445444205848544d4c20312e30205472616e736974696f6e616c2f2f454e222022687474703a2f2f7777772e77332e6f72672f54522f7868746d6c312f4454442f7868746d6c312d7472616e736974696f6e616c2e647464223e0d0a3c68746d6c20786d6c6e733d22687474703a2f2f7777772e77332e6f72672f313939392f7868746d6c220d0a09786d6c6e733a763d2275726e3a736368656d61732d6d6963726f736f66742d636f6d3a766d6c223e0d0a3c686561643e0d0a3c6d65746120687474702d65717569763d22436f6e74656e742d547970652220636f6e74656e743d22746578742f68746d6c3b20636861727365743d7574662d3822202f3e0d0a3c6d657461206e616d653d22534b5950455f544f4f4c4241522220636f6e74656e743d22534b5950455f544f4f4c4241525f5041525345525f434f4d50415449424c4522202f3e0d0a3c7469746c653e4765744c696e632040204e65772055736572204163636f756e742054656d702050617373776f726420437265617465643c2f7469746c653e0d0a3c7374796c6520747970653d22746578742f637373223e0d0a763a2a207b0d0a096265686176696f723a2075726c282364656661756c7423564d4c293b0d0a09646973706c61793a20696e6c696e652d626c6f636b0d0a7d0d0a3c2f7374796c653e0d0a3c2f686561643e0d0a3c626f64793e0d0a3c7461626c652077696474683d223539342220626f726465723d2230222063656c6c70616464696e673d2230222063656c6c73706163696e673d2230223e0d0a0d0a0d0a093c74723e0d0a09093c74643e0d0a09093c7461626c652077696474683d2231303025222063656c6c70616464696e673d2230222063656c6c73706163696e673d2230223e0d0a0909093c74723e0d0a090909093c74642076616c69676e3d22746f70220d0a09090909097374796c653d22666f6e742d73697a653a20313270783b20636f6c6f723a20233030303030303b206c696e652d6865696768743a20313530253b20666f6e742d66616d696c793a2056657264616e612c2047656e6576612c2073616e732d73657269663b223e0d0a0d0a090909093c7461626c652077696474683d22353936222063656c6c70616464696e673d2230222063656c6c73706163696e673d2230223e0d0a0d0a0d0a09090909093c74723e0d0a0909090909093c74642076616c69676e3d22746f70220d0a090909090909097374796c653d22666f6e742d73697a653a20313270783b20636f6c6f723a20233030303030303b206c696e652d6865696768743a20313530253b20666f6e742d66616d696c793a2056657264616e612c2047656e6576612c2073616e732d73657269663b223e0d0a0d0a0909090909093c7461626c652077696474683d22353936222063656c6c70616464696e673d2230222063656c6c73706163696e673d2230223e0d0a0d0a0d0a090909090909093c74723e0d0a09090909090909090d0a09090909090909093c74642077696474683d2235393622206865696768743d2238362220616c69676e3d226c656674220d0a0909090909090909097374796c653d22666f6e742d73697a653a20313270783b20636f6c6f723a20233030303030303b220d0a0909090909090909096261636b67726f756e643d22687474703a2f2f6c6f63616c686f73742f7a696e6762616e672f2f7075626c69632f656d61696c496d616765732f65786163742d70656e742d636f6c6f72732d6865616465722e6a7067223e0d0a09090909090909090d0a09090909090909093c7461626c652063656c6c70616464696e673d2230222063656c6c73706163696e673d22302220626f726465723d2230222077696474683d22353830223e0d0a0909090909090909093c74723e0d0a090909090909090909093c74642077696474683d223135223e3c2f74643e090909090909090909090d0a090909090909090909093c74642076616c69676e3d22746f70220d0a09090909090909090909097374796c653d22746578742d616c69676e3a206c6566743b20766572746963616c2d616c69676e3a20746f703b223e3c696d670d0a0909090909090909090909616c69676e3d226d6964646c6522207374796c653d22766572746963616c2d616c69676e3a206d6964646c653b2220626f726465723d2230220d0a09090909090909090909097372633d22687474703a2f2f6c6f63616c686f73742f7a696e6762616e672f2f7075626c69632f656d61696c496d616765732f70656e742d6c6f676f2d736d616c6c312e706e67220d0a0909090909090909090909616c743d224765744c696e6322202f3e3c2f74643e0d0a090909090909090909093c74642077696474683d223730223e3c2f74643e0d0a090909090909090909093c74642077696474683d223135223e3c2f74643e0d0a0909090909090909093c2f74723e0d0a09090909090909093c2f7461626c653e0d0a0d0a0d0a09090909090909093c2f74643e0d0a090909090909093c2f74723e0d0a0d0a0909090909093c2f7461626c653e0d0a0909090909093c2f74643e0d0a09090909093c2f74723e0d0a0d0a090909093c2f7461626c653e0d0a090909093c2f74643e0d0a0909093c2f74723e0d0a0d0a0d0a0d0a0909093c212d2d626f6479202d2d3e0d0a0d0a0909093c74723e0d0a090909093c74643e0d0a090909093c7461626c652077696474683d223539362220626f726465723d2230222063656c6c70616464696e673d2230222063656c6c73706163696e673d2230223e0d0a09090909093c74723e0909090909090d0a0909090909093c74642077696474683d223122206267636f6c6f723d2223623162316231223e3c2f74643e0d0a0909090909093c74643e0d0a0909090909093c7461626c652077696474683d223539342220616c69676e3d2263656e7465722220626f726465723d2230222063656c6c73706163696e673d2230223e0d0a0d0a090909090909093c74723e0d0a09090909090909093c7464207374796c653d226865696768743a203570783b223e3c2f74643e0d0a090909090909093c2f74723e0d0a090909090909093c74723e0d0a09090909090909093c7464206865696768743d223230220d0a0909090909090909097374796c653d22746578742d616c69676e3a2063656e7465723b20666f6e742d73697a653a20313570783b20666f6e742d66616d696c793a20417269616c2c2048656c7665746963612c2073616e732d73657269663b220d0a090909090909090909616c69676e3d2263656e746572223e3c7374726f6e673e4765744c696e633c2f7374726f6e673e3c2f74643e0d0a090909090909093c2f74723e0d0a090909090909093c74723e0d0a09090909090909093c7464206865696768743d223230220d0a0909090909090909097374796c653d22746578742d616c69676e3a2063656e7465723b20666f6e742d73697a653a20313570783b20666f6e742d66616d696c793a20417269616c2c2048656c7665746963612c2073616e732d73657269663b20626f726465722d626f74746f6d2d636f6c6f723a20236364636463643b20626f726465722d626f74746f6d2d7374796c653a20736f6c69643b20626f726465722d626f74746f6d2d77696474683a203270783b220d0a090909090909090909616c69676e3d2263656e746572223e3c7374726f6e673e4e65772055736572204163636f756e74202d0d0a090909090909090954656d706f726172792050617373776f72643c2f7374726f6e673e3c2f74643e0d0a090909090909093c2f74723e0d0a0d0a090909090909093c74723e0d0a0d0a09090909090909093c7464206267636f6c6f723d2223464646464646222076616c69676e3d22746f70222077696474683d22353935220d0a0909090909090909097374796c653d22666f6e742d73697a653a20313370783b20666f6e742d7765696768743a206e6f726d616c3b20636f6c6f723a20233537353735373b20666f6e742d66616d696c793a20617269616c3b206c696e652d6865696768743a20313530253b223e0d0a09090909090909093c7461626c652077696474683d22353930222063656c6c70616464696e673d2230222063656c6c73706163696e673d2230223e0d0a0d0a0909090909090909093c74723e0d0a090909090909090909093c74642077696474683d22313522206865696768743d2232223e3c2f74643e0d0a090909090909090909093c74643e3c2f74643e0d0a0909090909090909093c2f74723e0d0a0909090909090909093c74723e0d0a090909090909090909093c74642077696474683d22313522206865696768743d2235223e3c2f74643e0d0a090909090909090909093c74640d0a09090909090909090909097374796c653d22636f6c6f723a20233537353735373b20666f6e742d66616d696c793a20417269616c2c2048656c7665746963612c2073616e732d73657269663b20666f6e742d73697a653a20313370783b223e4a756e652030322c20323031333c2f74643e0d0a0909090909090909093c2f74723e0d0a0909090909090909093c74723e0d0a090909090909090909093c7464206865696768743d223130223e3c2f74643e0d0a0909090909090909093c2f74723e0d0a0d0a0909090909090909093c74723e0d0a090909090909090909093c74642077696474683d22313522206865696768743d2235223e3c2f74643e0d0a090909090909090909093c74640d0a09090909090909090909097374796c653d22666f6e742d66616d696c793a20417269616c2c2048656c7665746963612c2073616e732d73657269663b20666f6e742d73697a653a20313370783b20636f6c6f723a2023353735373537223e5265666572656e63653a0d0a090909090909090909093c656d3e537570657261646d696e2054776f203c2f656d3e3c2f74643e0d0a090909090909090909093c212d2d636f6c6f723a233263613366353b202d2d3e0d0a0909090909090909093c2f74723e0d0a0909090909090909093c74723e0d0a090909090909090909093c7464206865696768743d2238223e3c2f74643e0d0a0909090909090909093c2f74723e0d0a0d0a0909090909090909093c74723e0d0a090909090909090909093c74642077696474683d22313522206865696768743d2235223e3c2f74643e0d0a090909090909090909093c74640d0a09090909090909090909097374796c653d22636f6c6f723a20233537353735373b20666f6e742d66616d696c793a20417269616c2c2048656c7665746963612c2073616e732d73657269663b20666f6e742d73697a653a20313370783b2070616464696e672d746f703a203570783b223e3c623e57656c636f6d65213c2f623e0d0a09090909090909090909416e204163636f756e7420686173206265656e206372656174656420666f7220796f7520746f206163636573732074686520506f7274616c2e3c2f74643e0d0a0909090909090909093c2f74723e0d0a0d0a0909090909090909093c74723e0d0a090909090909090909093c74642077696474683d22313522206865696768743d2235223e3c2f74643e0d0a090909090909090909093c74640d0a09090909090909090909097374796c653d22636f6c6f723a20233537353735373b20666f6e742d66616d696c793a20417269616c2c2048656c7665746963612c2073616e732d73657269663b20666f6e742d73697a653a20313370783b2070616464696e672d746f703a203070783b223e44657461696c730d0a090909090909090909096f6620796f7572206163636f756e7420616e642061636365737320696e666f726d6174696f6e20617265206c69737465642062656c6f772e3c2f74643e0d0a0909090909090909093c2f74723e0d0a0d0a0d0a0d0a0909090909090909093c74723e0d0a090909090909090909093c7464206865696768743d2238223e3c2f74643e0d0a0909090909090909093c2f74723e0d0a0909090909090909093c74723e0d0a090909090909090909093c74642077696474683d22313522206865696768743d2235223e3c2f74643e0d0a090909090909090909093c74640d0a09090909090909090909097374796c653d22636f6c6f723a20233537353735373b20666f6e742d66616d696c793a20417269616c2c2048656c7665746963612c2073616e732d73657269663b20666f6e742d73697a653a20313370783b2070616464696e672d746f703a203570783b223e0d0a09090909090909090909506c6561736520636f6e7461637420796f75722053797374656d2041646d696e6973747261746f72207769746820616e79207175657374696f6e732e3c2f74643e0d0a0909090909090909093c2f74723e0d0a0d0a0909090909090909093c74723e0d0a090909090909090909093c7464206865696768743d2238223e3c2f74643e0d0a0909090909090909093c2f74723e0d0a0d0a09090909090909093c2f7461626c653e0d0a09090909090909093c2f74643e0d0a0d0a090909090909093c2f74723e0d0a0d0a090909090909093c74723e0d0a09090909090909090d0a09090909090909093c746420616c69676e3d226c656674222076616c69676e3d226d6964646c65220d0a0909090909090909097374796c653d22626f726465722d746f703a20233636362031707820736f6c69643b20626f726465722d626f74746f6d3a20233636362031707820736f6c69643b20666f6e742d73697a653a20313270783b20636f6c6f723a20233537353735373b20666f6e742d66616d696c793a20417269616c2c2048656c7665746963612c2073616e732d73657269663b223e0d0a09090909090909093c7461626c652077696474683d22353030222063656c6c70616464696e673d2230222063656c6c73706163696e673d22302220626f726465723d2230223e0d0a0d0a0d0a0909090909090909093c74723e0d0a090909090909090909093c74642077696474683d22313522206865696768743d2235223e3c2f74643e0d0a090909090909090909093c7464206865696768743d223235220d0a09090909090909090909097374796c653d22636f6c6f723a20233537353735373b20666f6e742d66616d696c793a20417269616c2c2048656c7665746963612c2073616e732d73657269663b20666f6e742d73697a653a20313370783b223e0d0a0d0a090909090909090909090d0a090909090909090909093c623e4163636f756e7420496e666f726d6174696f6e3a203c2f623e3c2f74643e0d0a0909090909090909093c2f74723e0d0a0d0a0d0a0909090909090909093c74723e0d0a090909090909090909093c74642077696474683d22313522206865696768743d2235223e3c2f74643e0d0a090909090909090909093c7464206865696768743d223230220d0a09090909090909090909097374796c653d22636f6c6f723a20233537353735373b20666f6e742d66616d696c793a20417269616c2c2048656c7665746963612c2073616e732d73657269663b20666f6e742d73697a653a20313370783b223e0d0a090909090909090909090d0a090909090909090909094669727374204e616d653a20537570657261646d696e3c2f74643e0d0a0909090909090909093c2f74723e0d0a0d0a0909090909090909093c74723e0d0a090909090909090909093c74642077696474683d22313522206865696768743d2235223e3c2f74643e0d0a090909090909090909093c7464206865696768743d223230220d0a09090909090909090909097374796c653d22636f6c6f723a20233537353735373b20666f6e742d66616d696c793a20417269616c2c2048656c7665746963612c2073616e732d73657269663b20666f6e742d73697a653a20313370783b223e4c6173740d0a090909090909090909094e616d653a2054776f3c2f74643e0d0a0909090909090909093c2f74723e0d0a0d0a0909090909090909093c74723e0d0a090909090909090909093c74642077696474683d22313522206865696768743d2235223e3c2f74643e0d0a090909090909090909093c7464206865696768743d223230220d0a09090909090909090909097374796c653d22636f6c6f723a20233537353735373b20666f6e742d66616d696c793a20417269616c2c2048656c7665746963612c2073616e732d73657269663b20666f6e742d73697a653a20313370783b223e526f6c653a0d0a09090909090909090909537570657261646d696e3c2f74643e0d0a0909090909090909093c2f74723e0d0a0d0a09090909090909093c2f7461626c653e0d0a0d0a09090909090909093c7461626c652077696474683d22353030222063656c6c70616464696e673d2230222063656c6c73706163696e673d22302220626f726465723d2230223e0d0a0d0a0d0a0909090909090909093c74723e0d0a090909090909090909093c74642077696474683d22313522206865696768743d2235223e3c2f74643e0d0a090909090909090909093c7464206865696768743d223235220d0a09090909090909090909097374796c653d22636f6c6f723a20233537353735373b20666f6e742d66616d696c793a20417269616c2c2048656c7665746963612c2073616e732d73657269663b20666f6e742d73697a653a20313370783b223e0d0a0d0a090909090909090909090d0a090909090909090909093c623e41636365737320496e666f726d6174696f6e3a3c2f623e3c2f74643e0d0a0909090909090909093c2f74723e0d0a0d0a0d0a0909090909090909093c74723e0d0a090909090909090909093c74642077696474683d22313522206865696768743d2235223e3c2f74643e0d0a090909090909090909093c7464206865696768743d223230220d0a09090909090909090909097374796c653d22636f6c6f723a20233537353735373b20666f6e742d66616d696c793a20417269616c2c2048656c7665746963612c2073616e732d73657269663b20666f6e742d73697a653a20313370783b223e0d0a090909090909090909090d0a0909090909090909090954656d706f726172792050617373776f72643a20306a49336e5131783c2f74643e0d0a0909090909090909093c2f74723e0d0a0d0a0909090909090909093c74723e0d0a090909090909090909093c74642077696474683d22313522206865696768743d2235223e3c2f74643e0d0a090909090909090909093c7464206865696768743d223330220d0a09090909090909090909097374796c653d22636f6c6f723a20233537353735373b20666f6e742d66616d696c793a20417269616c2c2048656c7665746963612c2073616e732d73657269663b20666f6e742d73697a653a20313370783b223e0d0a090909090909090909090d0a09090909090909090909466f6c6c6f772074686973206c696e6b20746f206163636573732074686520506f7274616c3a203c610d0a09090909090909090909097374796c653d22666f6e742d66616d696c793a20417269616c2c2048656c7665746963612c2073616e732d73657269663b20666f6e742d73697a653a20313370783b20636f6c6f723a2023353539626465220d0a0909090909090909090909687265663d2223223e687474703a2f2f6c6f63616c686f73742f7a696e6762616e672f3c2f613e3c2f74643e0d0a0909090909090909093c2f74723e0d0a0d0a09090909090909093c2f7461626c653e0d0a09090909090909093c2f74643e0d0a090909090909093c2f74723e0d0a0d0a0d0a0d0a090909090909090d0a0909090909093c2f7461626c653e0d0a0d0a0909090909093c2f74643e0d0a0909090909093c74642077696474683d223122206267636f6c6f723d2223623162316231223e3c2f74643e0d0a09090909093c2f74723e0d0a09090909093c74723e0d0a0909090909093c74642077696474683d223122206267636f6c6f723d2223623162316231223e3c2f74643e0d0a0909090909090d0a0909090909093c7464207374796c653d2270616464696e673a2030707820313070782030707820313070783b222076616c69676e3d226d6964646c65220d0a09090909090909616c69676e3d226c65667422206865696768743d223437223e0d0a0909090909093c700d0a090909090909097374796c653d22666f6e742d73697a653a20313170783b20666f6e742d66616d696c793a20417269616c2c2048656c7665746963612c2073616e732d73657269663b20636f6c6f723a20726762283130322c203130322c20313032293b20666f6e742d7765696768743a206e6f726d616c3b206d617267696e2d746f703a203570783b206d617267696e2d626f74746f6d3a203570783b20746578742d616c69676e3a206a757374696679223e446973636c61696d65723a3c62723e0d0a09090909090954686520696e666f726d6174696f6e20636f6e7461696e656420696e207468697320656c656374726f6e6963206d65737361676520616e6420616e790d0a0909090909096174746163686d656e747320746f2074686973206d6573736167652061726520696e74656e64656420666f7220746865206578636c757369766520757365206f660d0a0909090909097468652061646472657373656528732920616e64206d617920636f6e7461696e2070726f70726965746172792c20636f6e666964656e7469616c206f720d0a09090909090970726976696c6567656420696e666f726d6174696f6e2e20496620796f7520617265206e6f742074686520696e74656e64656420726563697069656e742c20796f750d0a09090909090973686f756c64206e6f742064697373656d696e6174652c2064697374726962757465206f7220636f7079207468697320652d6d61696c2e20506c656173650d0a09090909090964657374726f7920616c6c20636f70696573206f662074686973206d65737361676520616e6420616e79206174746163686d656e74732e200d0a0909090909093c2f703e0d0a0909090909093c2f74643e0d0a0909090909093c74642077696474683d223122206267636f6c6f723d2223623162316231223e3c2f74643e0d0a09090909093c2f74723e0d0a090909093c2f7461626c653e0d0a090909093c2f74643e0d0a0909093c2f74723e0d0a0d0a0d0a0d0a0d0a0d0a0d0a09093c2f7461626c653e0d0a09093c2f74643e0d0a093c2f74723e0d0a0d0a093c74723e0d0a09090d0a09093c74642077696474683d2235393622206865696768743d2237302220616c69676e3d226c656674220d0a0909097374796c653d226261636b67726f756e642d7265706561743a206e6f2d7265706561743b20666f6e742d73697a653a20313270783b20636f6c6f723a20233030303030303b20666f6e742d66616d696c793a20417269616c2c2048656c7665746963612c2073616e732d73657269663b220d0a0909096261636b67726f756e643d22687474703a2f2f6c6f63616c686f73742f7a696e6762616e672f2f7075626c69632f656d61696c496d616765732f65786163742d70656e742d636f6c6f72732d666f6f7465722e706e67223e0d0a09090d0a0d0a09093c7461626c6520626f726465723d2230222063656c6c70616464696e673d2230222063656c6c73706163696e673d2230222077696474683d22353830223e0d0a0909093c74723e0d0a090909093c74642077696474683d223135222076616c69676e3d22746f70223e3c2f74643e0d0a090909093c74642076616c69676e3d22746f70222077696474683d223635220d0a09090909097374796c653d22666f6e742d66616d696c793a20417269616c2c2048656c7665746963612c2073616e732d73657269663b20666f6e742d73697a653a20313070783b20666f6e742d7374796c653a206e6f726d616c3b20666f6e742d7765696768743a206e6f726d616c3b20636f6c6f723a20236666663b2070616464696e672d6c6566743a2033357078223e546869730d0a09090909646f63756d656e7420616e642074686520696e666f726d6174696f6e20636f6e7461696e6564207468657265696e2c206973207468652070726f70726965746172790d0a09090909616e6420636f6e666964656e7469616c20696e666f726d6174696f6e3c2f74643e0d0a0909093c2f74723e0d0a0d0a0909093c74723e0d0a090909093c74643e3c2f74643e0d0a090909093c74642077696474683d223830220d0a09090909097374796c653d22666f6e742d66616d696c793a20417269616c2c2048656c7665746963612c2073616e732d73657269663b20666f6e742d73697a653a20313070783b20666f6e742d7374796c653a206e6f726d616c3b20666f6e742d7765696768743a206e6f726d616c3b20636f6c6f723a20236666663b20746578742d616c69676e3a206a7573746966793b2070616464696e672d6c6566743a20343270783b223e6f660d0a090909094765744c696e632c20496e632e20616e642074686520646f63756d656e742c20616e642074686520696e666f726d6174696f6e0d0a09090909636f6e7461696e6564207468657265696e2c206d6179206e6f742062653c2f74643e0d0a0909093c2f74723e0d0a0d0a0909093c74723e0d0a090909093c74643e3c2f74643e0d0a090909093c74642077696474683d223830220d0a09090909097374796c653d22666f6e742d66616d696c793a20417269616c2c2048656c7665746963612c2073616e732d73657269663b20666f6e742d73697a653a20313070783b20666f6e742d7374796c653a206e6f726d616c3b20666f6e742d7765696768743a206e6f726d616c3b20636f6c6f723a20236666663b2070616464696e672d6c6566743a2034347078223e757365642c0d0a09090909636f706965642c206f7220646973636c6f73656420776974686f7574207468652065787072657373207072696f72207772697474656e20636f6e73656e74206f660d0a090909094765744c696e632c20496e632e3c2f74643e0d0a0909093c2f74723e0d0a0d0a0909093c74723e0d0a090909093c74643e3c2f74643e0d0a090909093c74642077696474683d223830220d0a09090909097374796c653d22666f6e742d66616d696c793a20417269616c2c2048656c7665746963612c2073616e732d73657269663b20666f6e742d73697a653a20313070783b20666f6e742d7374796c653a206e6f726d616c3b20666f6e742d7765696768743a20626f6c643b20636f6c6f723a20236666663b2070616464696e672d6c6566743a203133357078223e26233136390d0a0909090932303133204765744c696e632c20496e632e20416c6c207269676874732072657365727665642e3c2f74643e0d0a0909093c2f74723e0d0a09093c2f7461626c653e0d0a0d0a09093c2f74643e0d0a0d0a09090d0a0d0a093c2f74723e0d0a0d0a3c2f7461626c653e0d0a3c2f626f64793e0d0a3c2f68746d6c3e, 1, 1, '2013-06-02 13:55:37', '2013-06-02 08:25:37', NULL, 1, NULL, NULL);
INSERT INTO `apmmailqueue` (`mailqueueid`, `emailfrom`, `emailto`, `emailsubject`, `body`, `mailstatus`, `referenceid`, `createddatetime`, `updateddatetime`, `deleteddatetime`, `statusid`, `createdby`, `lastupdatedby`) VALUES
(26, 'support@getlinc.com', 'admin1@gmail.com', 'New User Account - Username', 0x3c21444f43545950452068746d6c205055424c494320222d2f2f5733432f2f445444205848544d4c20312e30205472616e736974696f6e616c2f2f454e222022687474703a2f2f7777772e77332e6f72672f54522f7868746d6c312f4454442f7868746d6c312d7472616e736974696f6e616c2e647464223e0d0a3c68746d6c20786d6c6e733d22687474703a2f2f7777772e77332e6f72672f313939392f7868746d6c220d0a09786d6c6e733a763d2275726e3a736368656d61732d6d6963726f736f66742d636f6d3a766d6c223e0d0a3c686561643e0d0a3c6d65746120687474702d65717569763d22436f6e74656e742d547970652220636f6e74656e743d22746578742f68746d6c3b20636861727365743d7574662d3822202f3e0d0a3c6d657461206e616d653d22534b5950455f544f4f4c4241522220636f6e74656e743d22534b5950455f544f4f4c4241525f5041525345525f434f4d50415449424c4522202f3e0d0a3c7469746c653e4765744c696e632040204e65772055736572204163636f756e7420557365726e616d6520437265617465643c2f7469746c653e0d0a3c7374796c6520747970653d22746578742f637373223e0d0a763a2a207b0d0a096265686176696f723a2075726c282364656661756c7423564d4c293b0d0a09646973706c61793a20696e6c696e652d626c6f636b0d0a7d0d0a3c2f7374796c653e0d0a3c2f686561643e0d0a3c626f64793e0d0a3c7461626c652077696474683d223539342220626f726465723d2230222063656c6c70616464696e673d2230222063656c6c73706163696e673d2230223e0d0a0d0a0d0a093c74723e0d0a09093c74643e0d0a09093c7461626c652077696474683d2231303025222063656c6c70616464696e673d2230222063656c6c73706163696e673d2230223e0d0a0909093c74723e0d0a090909093c74642076616c69676e3d22746f70220d0a09090909097374796c653d22666f6e742d73697a653a20313270783b20636f6c6f723a20233030303030303b206c696e652d6865696768743a20313530253b20666f6e742d66616d696c793a2056657264616e612c2047656e6576612c2073616e732d73657269663b223e0d0a0d0a090909093c7461626c652077696474683d22353936222063656c6c70616464696e673d2230222063656c6c73706163696e673d2230223e0d0a0d0a0d0a09090909093c74723e0d0a0909090909093c74642076616c69676e3d22746f70220d0a090909090909097374796c653d22666f6e742d73697a653a20313270783b20636f6c6f723a20233030303030303b206c696e652d6865696768743a20313530253b20666f6e742d66616d696c793a2056657264616e612c2047656e6576612c2073616e732d73657269663b223e0d0a0d0a0909090909093c7461626c652077696474683d22353936222063656c6c70616464696e673d2230222063656c6c73706163696e673d2230223e0d0a0d0a0d0a090909090909093c74723e0d0a09090909090909090d0a09090909090909093c74642077696474683d2235393622206865696768743d2238362220616c69676e3d226c656674220d0a0909090909090909097374796c653d22666f6e742d73697a653a20313270783b20636f6c6f723a20233030303030303b220d0a0909090909090909096261636b67726f756e643d2223736974656261736575726c2f7075626c69632f656d61696c496d616765732f65786163742d70656e742d636f6c6f72732d6865616465722e6a7067223e0d0a09090909090909090d0a09090909090909093c7461626c652063656c6c70616464696e673d2230222063656c6c73706163696e673d22302220626f726465723d2230222077696474683d22353830223e0d0a0909090909090909093c74723e0d0a090909090909090909093c74642077696474683d223135223e3c2f74643e0d0a090909090909090909090d0a090909090909090909093c74642076616c69676e3d22746f70220d0a09090909090909090909097374796c653d22746578742d616c69676e3a206c6566743b20766572746963616c2d616c69676e3a20746f703b223e3c696d670d0a0909090909090909090909616c69676e3d226d6964646c6522207374796c653d22766572746963616c2d616c69676e3a206d6964646c653b2220626f726465723d2230220d0a09090909090909090909097372633d2223736974656261736575726c2f7075626c69632f656d61696c496d616765732f70656e742d6c6f676f2d736d616c6c312e706e67220d0a0909090909090909090909616c743d224765744c696e6322202f3e3c2f74643e0d0a090909090909090909093c74642077696474683d223730223e3c2f74643e0d0a090909090909090909093c74642077696474683d223135223e3c2f74643e0d0a0909090909090909093c2f74723e0d0a09090909090909093c2f7461626c653e0d0a0d0a0d0a09090909090909093c2f74643e0d0a090909090909093c2f74723e0d0a0d0a0909090909093c2f7461626c653e0d0a0909090909093c2f74643e0d0a09090909093c2f74723e0d0a0d0a090909093c2f7461626c653e0d0a090909093c2f74643e0d0a0909093c2f74723e0d0a0d0a0d0a0d0a0909093c212d2d626f6479202d2d3e0d0a0d0a0909093c74723e0d0a090909093c74643e0d0a090909093c7461626c652077696474683d223539362220626f726465723d2230222063656c6c70616464696e673d2230222063656c6c73706163696e673d2230223e0d0a09090909093c74723e0909090909090d0a0909090909093c74642077696474683d223122206267636f6c6f723d2223623162316231223e3c2f74643e0d0a0909090909093c74643e0d0a0909090909093c7461626c652077696474683d223539342220616c69676e3d2263656e7465722220626f726465723d2230222063656c6c73706163696e673d2230223e0d0a0d0a090909090909093c74723e0d0a09090909090909093c7464207374796c653d226865696768743a203570783b223e3c2f74643e0d0a090909090909093c2f74723e0d0a090909090909093c74723e0d0a09090909090909093c7464206865696768743d223230220d0a0909090909090909097374796c653d22746578742d616c69676e3a2063656e7465723b20666f6e742d73697a653a20313570783b20666f6e742d66616d696c793a20417269616c2c2048656c7665746963612c2073616e732d73657269663b220d0a090909090909090909616c69676e3d2263656e746572223e3c7374726f6e673e4765744c696e633c2f7374726f6e673e3c2f74643e0d0a090909090909093c2f74723e0d0a090909090909093c74723e0d0a09090909090909093c7464206865696768743d223230220d0a0909090909090909097374796c653d22746578742d616c69676e3a2063656e7465723b20666f6e742d73697a653a20313570783b20666f6e742d66616d696c793a20417269616c2c2048656c7665746963612c2073616e732d73657269663b20626f726465722d626f74746f6d2d636f6c6f723a20236364636463643b20626f726465722d626f74746f6d2d7374796c653a20736f6c69643b20626f726465722d626f74746f6d2d77696474683a203270783b220d0a090909090909090909616c69676e3d2263656e746572223e3c7374726f6e673e4e65772055736572204163636f756e74202d0d0a0909090909090909557365726e616d653c2f7374726f6e673e3c2f74643e0d0a090909090909093c2f74723e0d0a0d0a090909090909093c74723e0d0a0d0a09090909090909093c7464206267636f6c6f723d2223464646464646222076616c69676e3d22746f70222077696474683d22353935220d0a0909090909090909097374796c653d22666f6e742d73697a653a20313370783b20666f6e742d7765696768743a206e6f726d616c3b20636f6c6f723a20233537353735373b20666f6e742d66616d696c793a20617269616c3b206c696e652d6865696768743a20313530253b223e0d0a09090909090909093c7461626c652077696474683d22353930222063656c6c70616464696e673d2230222063656c6c73706163696e673d2230223e0d0a0d0a0909090909090909093c74723e0d0a090909090909090909093c74642077696474683d22313522206865696768743d2232223e3c2f74643e0d0a090909090909090909093c74643e3c2f74643e0d0a0909090909090909093c2f74723e0d0a0909090909090909093c74723e0d0a090909090909090909093c74642077696474683d22313522206865696768743d2235223e3c2f74643e0d0a090909090909090909093c74640d0a09090909090909090909097374796c653d22636f6c6f723a20233537353735373b20666f6e742d66616d696c793a20417269616c2c2048656c7665746963612c2073616e732d73657269663b20666f6e742d73697a653a20313370783b223e4a756e652030322c20323031333c2f74643e0d0a0909090909090909093c2f74723e0d0a0909090909090909093c74723e0d0a090909090909090909093c7464206865696768743d223130223e3c2f74643e0d0a0909090909090909093c2f74723e0d0a0d0a0909090909090909093c74723e0d0a090909090909090909093c74642077696474683d22313522206865696768743d2235223e3c2f74643e0d0a090909090909090909093c74640d0a09090909090909090909097374796c653d22666f6e742d66616d696c793a20417269616c2c2048656c7665746963612c2073616e732d73657269663b20666f6e742d73697a653a20313370783b20636f6c6f723a2023353735373537223e5265666572656e63653a0d0a090909090909090909093c656d3e41646d696e204f6e653c2f656d3e3c2f74643e0d0a090909090909090909090d0a0909090909090909093c2f74723e0d0a0909090909090909093c74723e0d0a090909090909090909093c7464206865696768743d2238223e3c2f74643e0d0a0909090909090909093c2f74723e0d0a0d0a0909090909090909093c74723e0d0a090909090909090909093c74642077696474683d22313522206865696768743d2235223e3c2f74643e0d0a090909090909090909093c74640d0a09090909090909090909097374796c653d22636f6c6f723a20233537353735373b20666f6e742d66616d696c793a20417269616c2c2048656c7665746963612c2073616e732d73657269663b20666f6e742d73697a653a20313370783b2070616464696e672d746f703a203570783b223e3c623e57656c636f6d65213c2f623e0d0a09090909090909090909416e204163636f756e7420686173206265656e206372656174656420666f7220796f7520746f206163636573732074686520506f7274616c2e3c2f74643e0d0a0909090909090909093c2f74723e0d0a0d0a0909090909090909093c74723e0d0a090909090909090909093c74642077696474683d22313522206865696768743d2235223e3c2f74643e0d0a090909090909090909093c74640d0a09090909090909090909097374796c653d22636f6c6f723a20233537353735373b20666f6e742d66616d696c793a20417269616c2c2048656c7665746963612c2073616e732d73657269663b20666f6e742d73697a653a20313370783b2070616464696e672d746f703a203070783b223e44657461696c730d0a090909090909090909096f6620796f7572206163636f756e7420616e642061636365737320696e666f726d6174696f6e20617265206c69737465642062656c6f772e3c2f74643e0d0a0909090909090909093c2f74723e0d0a0d0a0d0a0d0a0909090909090909093c74723e0d0a090909090909090909093c7464206865696768743d2238223e3c2f74643e0d0a0909090909090909093c2f74723e0d0a0909090909090909093c74723e0d0a090909090909090909093c74642077696474683d22313522206865696768743d2235223e3c2f74643e0d0a090909090909090909093c74640d0a09090909090909090909097374796c653d22636f6c6f723a20233537353735373b20666f6e742d66616d696c793a20417269616c2c2048656c7665746963612c2073616e732d73657269663b20666f6e742d73697a653a20313370783b2070616464696e672d746f703a203570783b223e0d0a09090909090909090909506c6561736520636f6e7461637420796f75722053797374656d2041646d696e6973747261746f72207769746820616e79207175657374696f6e732e3c2f74643e0d0a0909090909090909093c2f74723e0d0a0d0a0909090909090909093c74723e0d0a090909090909090909093c7464206865696768743d2238223e3c2f74643e0d0a0909090909090909093c2f74723e0d0a0d0a09090909090909093c2f7461626c653e0d0a09090909090909093c2f74643e0d0a0d0a090909090909093c2f74723e0d0a0d0a090909090909093c74723e0d0a09090909090909090d0a09090909090909093c746420616c69676e3d226c656674222076616c69676e3d226d6964646c65220d0a0909090909090909097374796c653d22626f726465722d746f703a20233636362031707820736f6c69643b20626f726465722d626f74746f6d3a20233636362031707820736f6c69643b20666f6e742d73697a653a20313270783b20636f6c6f723a20233537353735373b20666f6e742d66616d696c793a20417269616c2c2048656c7665746963612c2073616e732d73657269663b223e0d0a09090909090909093c7461626c652077696474683d22353030222063656c6c70616464696e673d2230222063656c6c73706163696e673d22302220626f726465723d2230223e0d0a0d0a0d0a0909090909090909093c74723e0d0a090909090909090909093c74642077696474683d22313522206865696768743d2235223e3c2f74643e0d0a090909090909090909093c7464206865696768743d223235220d0a09090909090909090909097374796c653d22636f6c6f723a20233537353735373b20666f6e742d66616d696c793a20417269616c2c2048656c7665746963612c2073616e732d73657269663b20666f6e742d73697a653a20313370783b223e0d0a0d0a090909090909090909090d0a090909090909090909093c623e4163636f756e7420496e666f726d6174696f6e3a203c2f623e3c2f74643e0d0a0909090909090909093c2f74723e0d0a0d0a0d0a0909090909090909093c74723e0d0a090909090909090909093c74642077696474683d22313522206865696768743d2235223e3c2f74643e0d0a090909090909090909093c7464206865696768743d223230220d0a09090909090909090909097374796c653d22636f6c6f723a20233537353735373b20666f6e742d66616d696c793a20417269616c2c2048656c7665746963612c2073616e732d73657269663b20666f6e742d73697a653a20313370783b223e0d0a090909090909090909090d0a090909090909090909094669727374204e616d653a2041646d696e3c2f74643e0d0a0909090909090909093c2f74723e0d0a0d0a0909090909090909093c74723e0d0a090909090909090909093c74642077696474683d22313522206865696768743d2235223e3c2f74643e0d0a090909090909090909093c7464206865696768743d223230220d0a09090909090909090909097374796c653d22636f6c6f723a20233537353735373b20666f6e742d66616d696c793a20417269616c2c2048656c7665746963612c2073616e732d73657269663b20666f6e742d73697a653a20313370783b223e4c6173740d0a090909090909090909094e616d653a204f6e653c2f74643e0d0a0909090909090909093c2f74723e0d0a0d0a0909090909090909093c74723e0d0a090909090909090909093c74642077696474683d22313522206865696768743d2235223e3c2f74643e0d0a090909090909090909093c7464206865696768743d223230220d0a09090909090909090909097374796c653d22636f6c6f723a20233537353735373b20666f6e742d66616d696c793a20417269616c2c2048656c7665746963612c2073616e732d73657269663b20666f6e742d73697a653a20313370783b223e526f6c653a0d0a0909090909090909090941646d696e3c2f74643e0d0a0909090909090909093c2f74723e0d0a0d0a09090909090909093c2f7461626c653e0d0a0d0a09090909090909093c7461626c652077696474683d22353030222063656c6c70616464696e673d2230222063656c6c73706163696e673d22302220626f726465723d2230223e0d0a0d0a0d0a0909090909090909093c74723e0d0a090909090909090909093c74642077696474683d22313522206865696768743d2235223e3c2f74643e0d0a090909090909090909093c7464206865696768743d223235220d0a09090909090909090909097374796c653d22636f6c6f723a20233537353735373b20666f6e742d66616d696c793a20417269616c2c2048656c7665746963612c2073616e732d73657269663b20666f6e742d73697a653a20313370783b223e0d0a0d0a090909090909090909090d0a090909090909090909093c623e41636365737320496e666f726d6174696f6e3a3c2f623e3c2f74643e0d0a0909090909090909093c2f74723e0d0a0d0a0d0a0909090909090909093c74723e0d0a090909090909090909093c74642077696474683d22313522206865696768743d2235223e3c2f74643e0d0a090909090909090909093c7464206865696768743d223230220d0a09090909090909090909097374796c653d22636f6c6f723a20233537353735373b20666f6e742d66616d696c793a20417269616c2c2048656c7665746963612c2073616e732d73657269663b20666f6e742d73697a653a20313370783b223e0d0a090909090909090909090d0a09090909090909090909557365726e616d653a2061646d696e3140676d61696c2e636f6d3c2f74643e0d0a0909090909090909093c2f74723e0d0a0d0a0909090909090909093c74723e0d0a090909090909090909093c74642077696474683d22313522206865696768743d2235223e3c2f74643e0d0a090909090909090909093c7464206865696768743d223330220d0a09090909090909090909097374796c653d22636f6c6f723a20233537353735373b20666f6e742d66616d696c793a20417269616c2c2048656c7665746963612c2073616e732d73657269663b20666f6e742d73697a653a20313370783b223e0d0a090909090909090909090d0a090909090909090909093c656d3e596f75722074656d706f726172792070617373776f72642077696c6c2062652073656e7420696e20612073657061726174650d0a09090909090909090909656d61696c2e203c2f656d3e3c2f74643e0d0a0909090909090909093c2f74723e0d0a0d0a09090909090909093c2f7461626c653e0d0a09090909090909093c2f74643e0d0a090909090909093c2f74723e0d0a0d0a0d0a0d0a090909090909090d0a0909090909093c2f7461626c653e0d0a0d0a0909090909093c2f74643e0d0a0909090909093c74642077696474683d223122206267636f6c6f723d2223623162316231223e3c2f74643e0d0a09090909093c2f74723e0d0a09090909093c74723e0d0a0909090909093c74642077696474683d223122206267636f6c6f723d2223623162316231223e3c2f74643e0d0a0d0a0909090909090d0a0909090909093c7464207374796c653d2270616464696e673a2030707820313070782030707820313070783b222076616c69676e3d226d6964646c65220d0a09090909090909616c69676e3d226c65667422206865696768743d223437223e0d0a0909090909093c700d0a090909090909097374796c653d22666f6e742d73697a653a20313170783b20666f6e742d66616d696c793a20417269616c2c2048656c7665746963612c2073616e732d73657269663b20636f6c6f723a20726762283130322c203130322c20313032293b20666f6e742d7765696768743a206e6f726d616c3b206d617267696e2d746f703a203570783b206d617267696e2d626f74746f6d3a203570783b20746578742d616c69676e3a206a757374696679223e446973636c61696d65723a3c62723e0d0a09090909090954686520696e666f726d6174696f6e20636f6e7461696e656420696e207468697320656c656374726f6e6963206d65737361676520616e6420616e790d0a0909090909096174746163686d656e747320746f2074686973206d6573736167652061726520696e74656e64656420666f7220746865206578636c757369766520757365206f660d0a0909090909097468652061646472657373656528732920616e64206d617920636f6e7461696e2070726f70726965746172792c20636f6e666964656e7469616c206f720d0a09090909090970726976696c6567656420696e666f726d6174696f6e2e20496620796f7520617265206e6f742074686520696e74656e64656420726563697069656e742c20796f750d0a09090909090973686f756c64206e6f742064697373656d696e6174652c2064697374726962757465206f7220636f7079207468697320652d6d61696c2e20506c656173650d0a09090909090964657374726f7920616c6c20636f70696573206f662074686973206d65737361676520616e6420616e79206174746163686d656e74732e200d0a0909090909093c2f703e0d0a0909090909093c2f74643e0d0a0909090909093c74642077696474683d223122206267636f6c6f723d2223623162316231223e3c2f74643e0d0a09090909093c2f74723e0d0a090909093c2f7461626c653e0d0a090909093c2f74643e0d0a0909093c2f74723e0d0a0d0a0d0a0d0a0d0a0d0a0d0a09093c2f7461626c653e0d0a09093c2f74643e0d0a093c2f74723e0d0a0d0a093c74723e0d0a09090d0a09093c74642077696474683d2235393622206865696768743d2237302220616c69676e3d226c656674220d0a0909097374796c653d226261636b67726f756e642d7265706561743a206e6f2d7265706561743b20666f6e742d73697a653a20313270783b20636f6c6f723a20233030303030303b20666f6e742d66616d696c793a20417269616c2c2048656c7665746963612c2073616e732d73657269663b220d0a0909096261636b67726f756e643d2223736974656261736575726c2f7075626c69632f656d61696c496d616765732f65786163742d70656e742d636f6c6f72732d666f6f7465722e706e67223e0d0a09090d0a0d0a09093c7461626c6520626f726465723d2230222063656c6c70616464696e673d2230222063656c6c73706163696e673d2230222077696474683d22353830223e0d0a0909093c74723e0d0a090909093c74642077696474683d223135222076616c69676e3d22746f70223e3c2f74643e0d0a090909093c74642076616c69676e3d22746f70222077696474683d223635220d0a09090909097374796c653d22666f6e742d66616d696c793a20417269616c2c2048656c7665746963612c2073616e732d73657269663b20666f6e742d73697a653a20313070783b20666f6e742d7374796c653a206e6f726d616c3b20666f6e742d7765696768743a206e6f726d616c3b20636f6c6f723a20236666663b2070616464696e672d6c6566743a2033357078223e546869730d0a09090909646f63756d656e7420616e642074686520696e666f726d6174696f6e20636f6e7461696e6564207468657265696e2c206973207468652070726f70726965746172790d0a09090909616e6420636f6e666964656e7469616c20696e666f726d6174696f6e3c2f74643e0d0a0909093c2f74723e0d0a0d0a0909093c74723e0d0a090909093c74643e3c2f74643e0d0a090909093c74642077696474683d223830220d0a09090909097374796c653d22666f6e742d66616d696c793a20417269616c2c2048656c7665746963612c2073616e732d73657269663b20666f6e742d73697a653a20313070783b20666f6e742d7374796c653a206e6f726d616c3b20666f6e742d7765696768743a206e6f726d616c3b20636f6c6f723a20236666663b20746578742d616c69676e3a206a7573746966793b2070616464696e672d6c6566743a20343270783b223e6f660d0a090909094765744c696e632c20496e632e20616e642074686520646f63756d656e742c20616e642074686520696e666f726d6174696f6e0d0a09090909636f6e7461696e6564207468657265696e2c206d6179206e6f742062653c2f74643e0d0a0909093c2f74723e0d0a0d0a0909093c74723e0d0a090909093c74643e3c2f74643e0d0a090909093c74642077696474683d223830220d0a09090909097374796c653d22666f6e742d66616d696c793a20417269616c2c2048656c7665746963612c2073616e732d73657269663b20666f6e742d73697a653a20313070783b20666f6e742d7374796c653a206e6f726d616c3b20666f6e742d7765696768743a206e6f726d616c3b20636f6c6f723a20236666663b2070616464696e672d6c6566743a2034347078223e757365642c0d0a09090909636f706965642c206f7220646973636c6f73656420776974686f7574207468652065787072657373207072696f72207772697474656e20636f6e73656e74206f660d0a090909094765744c696e632c20496e632e3c2f74643e0d0a0909093c2f74723e0d0a0d0a0909093c74723e0d0a090909093c74643e3c2f74643e0d0a090909093c74642077696474683d223830220d0a09090909097374796c653d22666f6e742d66616d696c793a20417269616c2c2048656c7665746963612c2073616e732d73657269663b20666f6e742d73697a653a20313070783b20666f6e742d7374796c653a206e6f726d616c3b20666f6e742d7765696768743a20626f6c643b20636f6c6f723a20236666663b2070616464696e672d6c6566743a203133357078223e26233136390d0a0909090932303133204765744c696e632c20496e632e20416c6c207269676874732072657365727665642e3c2f74643e0d0a0909093c2f74723e0d0a09093c2f7461626c653e0d0a0d0a09093c2f74643e0d0a0d0a09090d0a0d0a093c2f74723e0d0a0d0a3c2f7461626c653e0d0a3c2f626f64793e0d0a3c2f68746d6c3e, 1, NULL, '2013-06-02 14:26:04', '2013-06-02 08:56:04', NULL, 1, NULL, NULL),
(27, 'support@getlinc.com', 'admin1@gmail.com', 'New User Account - Temporary Password', 0x3c21444f43545950452068746d6c205055424c494320222d2f2f5733432f2f445444205848544d4c20312e30205472616e736974696f6e616c2f2f454e222022687474703a2f2f7777772e77332e6f72672f54522f7868746d6c312f4454442f7868746d6c312d7472616e736974696f6e616c2e647464223e0d0a3c68746d6c20786d6c6e733d22687474703a2f2f7777772e77332e6f72672f313939392f7868746d6c220d0a09786d6c6e733a763d2275726e3a736368656d61732d6d6963726f736f66742d636f6d3a766d6c223e0d0a3c686561643e0d0a3c6d65746120687474702d65717569763d22436f6e74656e742d547970652220636f6e74656e743d22746578742f68746d6c3b20636861727365743d7574662d3822202f3e0d0a3c6d657461206e616d653d22534b5950455f544f4f4c4241522220636f6e74656e743d22534b5950455f544f4f4c4241525f5041525345525f434f4d50415449424c4522202f3e0d0a3c7469746c653e4765744c696e632040204e65772055736572204163636f756e742054656d702050617373776f726420437265617465643c2f7469746c653e0d0a3c7374796c6520747970653d22746578742f637373223e0d0a763a2a207b0d0a096265686176696f723a2075726c282364656661756c7423564d4c293b0d0a09646973706c61793a20696e6c696e652d626c6f636b0d0a7d0d0a3c2f7374796c653e0d0a3c2f686561643e0d0a3c626f64793e0d0a3c7461626c652077696474683d223539342220626f726465723d2230222063656c6c70616464696e673d2230222063656c6c73706163696e673d2230223e0d0a0d0a0d0a093c74723e0d0a09093c74643e0d0a09093c7461626c652077696474683d2231303025222063656c6c70616464696e673d2230222063656c6c73706163696e673d2230223e0d0a0909093c74723e0d0a090909093c74642076616c69676e3d22746f70220d0a09090909097374796c653d22666f6e742d73697a653a20313270783b20636f6c6f723a20233030303030303b206c696e652d6865696768743a20313530253b20666f6e742d66616d696c793a2056657264616e612c2047656e6576612c2073616e732d73657269663b223e0d0a0d0a090909093c7461626c652077696474683d22353936222063656c6c70616464696e673d2230222063656c6c73706163696e673d2230223e0d0a0d0a0d0a09090909093c74723e0d0a0909090909093c74642076616c69676e3d22746f70220d0a090909090909097374796c653d22666f6e742d73697a653a20313270783b20636f6c6f723a20233030303030303b206c696e652d6865696768743a20313530253b20666f6e742d66616d696c793a2056657264616e612c2047656e6576612c2073616e732d73657269663b223e0d0a0d0a0909090909093c7461626c652077696474683d22353936222063656c6c70616464696e673d2230222063656c6c73706163696e673d2230223e0d0a0d0a0d0a090909090909093c74723e0d0a09090909090909090d0a09090909090909093c74642077696474683d2235393622206865696768743d2238362220616c69676e3d226c656674220d0a0909090909090909097374796c653d22666f6e742d73697a653a20313270783b20636f6c6f723a20233030303030303b220d0a0909090909090909096261636b67726f756e643d22687474703a2f2f6c6f63616c686f73742f7a696e6762616e672f2f7075626c69632f656d61696c496d616765732f65786163742d70656e742d636f6c6f72732d6865616465722e6a7067223e0d0a09090909090909090d0a09090909090909093c7461626c652063656c6c70616464696e673d2230222063656c6c73706163696e673d22302220626f726465723d2230222077696474683d22353830223e0d0a0909090909090909093c74723e0d0a090909090909090909093c74642077696474683d223135223e3c2f74643e090909090909090909090d0a090909090909090909093c74642076616c69676e3d22746f70220d0a09090909090909090909097374796c653d22746578742d616c69676e3a206c6566743b20766572746963616c2d616c69676e3a20746f703b223e3c696d670d0a0909090909090909090909616c69676e3d226d6964646c6522207374796c653d22766572746963616c2d616c69676e3a206d6964646c653b2220626f726465723d2230220d0a09090909090909090909097372633d22687474703a2f2f6c6f63616c686f73742f7a696e6762616e672f2f7075626c69632f656d61696c496d616765732f70656e742d6c6f676f2d736d616c6c312e706e67220d0a0909090909090909090909616c743d224765744c696e6322202f3e3c2f74643e0d0a090909090909090909093c74642077696474683d223730223e3c2f74643e0d0a090909090909090909093c74642077696474683d223135223e3c2f74643e0d0a0909090909090909093c2f74723e0d0a09090909090909093c2f7461626c653e0d0a0d0a0d0a09090909090909093c2f74643e0d0a090909090909093c2f74723e0d0a0d0a0909090909093c2f7461626c653e0d0a0909090909093c2f74643e0d0a09090909093c2f74723e0d0a0d0a090909093c2f7461626c653e0d0a090909093c2f74643e0d0a0909093c2f74723e0d0a0d0a0d0a0d0a0909093c212d2d626f6479202d2d3e0d0a0d0a0909093c74723e0d0a090909093c74643e0d0a090909093c7461626c652077696474683d223539362220626f726465723d2230222063656c6c70616464696e673d2230222063656c6c73706163696e673d2230223e0d0a09090909093c74723e0909090909090d0a0909090909093c74642077696474683d223122206267636f6c6f723d2223623162316231223e3c2f74643e0d0a0909090909093c74643e0d0a0909090909093c7461626c652077696474683d223539342220616c69676e3d2263656e7465722220626f726465723d2230222063656c6c73706163696e673d2230223e0d0a0d0a090909090909093c74723e0d0a09090909090909093c7464207374796c653d226865696768743a203570783b223e3c2f74643e0d0a090909090909093c2f74723e0d0a090909090909093c74723e0d0a09090909090909093c7464206865696768743d223230220d0a0909090909090909097374796c653d22746578742d616c69676e3a2063656e7465723b20666f6e742d73697a653a20313570783b20666f6e742d66616d696c793a20417269616c2c2048656c7665746963612c2073616e732d73657269663b220d0a090909090909090909616c69676e3d2263656e746572223e3c7374726f6e673e4765744c696e633c2f7374726f6e673e3c2f74643e0d0a090909090909093c2f74723e0d0a090909090909093c74723e0d0a09090909090909093c7464206865696768743d223230220d0a0909090909090909097374796c653d22746578742d616c69676e3a2063656e7465723b20666f6e742d73697a653a20313570783b20666f6e742d66616d696c793a20417269616c2c2048656c7665746963612c2073616e732d73657269663b20626f726465722d626f74746f6d2d636f6c6f723a20236364636463643b20626f726465722d626f74746f6d2d7374796c653a20736f6c69643b20626f726465722d626f74746f6d2d77696474683a203270783b220d0a090909090909090909616c69676e3d2263656e746572223e3c7374726f6e673e4e65772055736572204163636f756e74202d0d0a090909090909090954656d706f726172792050617373776f72643c2f7374726f6e673e3c2f74643e0d0a090909090909093c2f74723e0d0a0d0a090909090909093c74723e0d0a0d0a09090909090909093c7464206267636f6c6f723d2223464646464646222076616c69676e3d22746f70222077696474683d22353935220d0a0909090909090909097374796c653d22666f6e742d73697a653a20313370783b20666f6e742d7765696768743a206e6f726d616c3b20636f6c6f723a20233537353735373b20666f6e742d66616d696c793a20617269616c3b206c696e652d6865696768743a20313530253b223e0d0a09090909090909093c7461626c652077696474683d22353930222063656c6c70616464696e673d2230222063656c6c73706163696e673d2230223e0d0a0d0a0909090909090909093c74723e0d0a090909090909090909093c74642077696474683d22313522206865696768743d2232223e3c2f74643e0d0a090909090909090909093c74643e3c2f74643e0d0a0909090909090909093c2f74723e0d0a0909090909090909093c74723e0d0a090909090909090909093c74642077696474683d22313522206865696768743d2235223e3c2f74643e0d0a090909090909090909093c74640d0a09090909090909090909097374796c653d22636f6c6f723a20233537353735373b20666f6e742d66616d696c793a20417269616c2c2048656c7665746963612c2073616e732d73657269663b20666f6e742d73697a653a20313370783b223e4a756e652030322c20323031333c2f74643e0d0a0909090909090909093c2f74723e0d0a0909090909090909093c74723e0d0a090909090909090909093c7464206865696768743d223130223e3c2f74643e0d0a0909090909090909093c2f74723e0d0a0d0a0909090909090909093c74723e0d0a090909090909090909093c74642077696474683d22313522206865696768743d2235223e3c2f74643e0d0a090909090909090909093c74640d0a09090909090909090909097374796c653d22666f6e742d66616d696c793a20417269616c2c2048656c7665746963612c2073616e732d73657269663b20666f6e742d73697a653a20313370783b20636f6c6f723a2023353735373537223e5265666572656e63653a0d0a090909090909090909093c656d3e41646d696e204f6e65203c2f656d3e3c2f74643e0d0a090909090909090909093c212d2d636f6c6f723a233263613366353b202d2d3e0d0a0909090909090909093c2f74723e0d0a0909090909090909093c74723e0d0a090909090909090909093c7464206865696768743d2238223e3c2f74643e0d0a0909090909090909093c2f74723e0d0a0d0a0909090909090909093c74723e0d0a090909090909090909093c74642077696474683d22313522206865696768743d2235223e3c2f74643e0d0a090909090909090909093c74640d0a09090909090909090909097374796c653d22636f6c6f723a20233537353735373b20666f6e742d66616d696c793a20417269616c2c2048656c7665746963612c2073616e732d73657269663b20666f6e742d73697a653a20313370783b2070616464696e672d746f703a203570783b223e3c623e57656c636f6d65213c2f623e0d0a09090909090909090909416e204163636f756e7420686173206265656e206372656174656420666f7220796f7520746f206163636573732074686520506f7274616c2e3c2f74643e0d0a0909090909090909093c2f74723e0d0a0d0a0909090909090909093c74723e0d0a090909090909090909093c74642077696474683d22313522206865696768743d2235223e3c2f74643e0d0a090909090909090909093c74640d0a09090909090909090909097374796c653d22636f6c6f723a20233537353735373b20666f6e742d66616d696c793a20417269616c2c2048656c7665746963612c2073616e732d73657269663b20666f6e742d73697a653a20313370783b2070616464696e672d746f703a203070783b223e44657461696c730d0a090909090909090909096f6620796f7572206163636f756e7420616e642061636365737320696e666f726d6174696f6e20617265206c69737465642062656c6f772e3c2f74643e0d0a0909090909090909093c2f74723e0d0a0d0a0d0a0d0a0909090909090909093c74723e0d0a090909090909090909093c7464206865696768743d2238223e3c2f74643e0d0a0909090909090909093c2f74723e0d0a0909090909090909093c74723e0d0a090909090909090909093c74642077696474683d22313522206865696768743d2235223e3c2f74643e0d0a090909090909090909093c74640d0a09090909090909090909097374796c653d22636f6c6f723a20233537353735373b20666f6e742d66616d696c793a20417269616c2c2048656c7665746963612c2073616e732d73657269663b20666f6e742d73697a653a20313370783b2070616464696e672d746f703a203570783b223e0d0a09090909090909090909506c6561736520636f6e7461637420796f75722053797374656d2041646d696e6973747261746f72207769746820616e79207175657374696f6e732e3c2f74643e0d0a0909090909090909093c2f74723e0d0a0d0a0909090909090909093c74723e0d0a090909090909090909093c7464206865696768743d2238223e3c2f74643e0d0a0909090909090909093c2f74723e0d0a0d0a09090909090909093c2f7461626c653e0d0a09090909090909093c2f74643e0d0a0d0a090909090909093c2f74723e0d0a0d0a090909090909093c74723e0d0a09090909090909090d0a09090909090909093c746420616c69676e3d226c656674222076616c69676e3d226d6964646c65220d0a0909090909090909097374796c653d22626f726465722d746f703a20233636362031707820736f6c69643b20626f726465722d626f74746f6d3a20233636362031707820736f6c69643b20666f6e742d73697a653a20313270783b20636f6c6f723a20233537353735373b20666f6e742d66616d696c793a20417269616c2c2048656c7665746963612c2073616e732d73657269663b223e0d0a09090909090909093c7461626c652077696474683d22353030222063656c6c70616464696e673d2230222063656c6c73706163696e673d22302220626f726465723d2230223e0d0a0d0a0d0a0909090909090909093c74723e0d0a090909090909090909093c74642077696474683d22313522206865696768743d2235223e3c2f74643e0d0a090909090909090909093c7464206865696768743d223235220d0a09090909090909090909097374796c653d22636f6c6f723a20233537353735373b20666f6e742d66616d696c793a20417269616c2c2048656c7665746963612c2073616e732d73657269663b20666f6e742d73697a653a20313370783b223e0d0a0d0a090909090909090909090d0a090909090909090909093c623e4163636f756e7420496e666f726d6174696f6e3a203c2f623e3c2f74643e0d0a0909090909090909093c2f74723e0d0a0d0a0d0a0909090909090909093c74723e0d0a090909090909090909093c74642077696474683d22313522206865696768743d2235223e3c2f74643e0d0a090909090909090909093c7464206865696768743d223230220d0a09090909090909090909097374796c653d22636f6c6f723a20233537353735373b20666f6e742d66616d696c793a20417269616c2c2048656c7665746963612c2073616e732d73657269663b20666f6e742d73697a653a20313370783b223e0d0a090909090909090909090d0a090909090909090909094669727374204e616d653a2041646d696e3c2f74643e0d0a0909090909090909093c2f74723e0d0a0d0a0909090909090909093c74723e0d0a090909090909090909093c74642077696474683d22313522206865696768743d2235223e3c2f74643e0d0a090909090909090909093c7464206865696768743d223230220d0a09090909090909090909097374796c653d22636f6c6f723a20233537353735373b20666f6e742d66616d696c793a20417269616c2c2048656c7665746963612c2073616e732d73657269663b20666f6e742d73697a653a20313370783b223e4c6173740d0a090909090909090909094e616d653a204f6e653c2f74643e0d0a0909090909090909093c2f74723e0d0a0d0a0909090909090909093c74723e0d0a090909090909090909093c74642077696474683d22313522206865696768743d2235223e3c2f74643e0d0a090909090909090909093c7464206865696768743d223230220d0a09090909090909090909097374796c653d22636f6c6f723a20233537353735373b20666f6e742d66616d696c793a20417269616c2c2048656c7665746963612c2073616e732d73657269663b20666f6e742d73697a653a20313370783b223e526f6c653a0d0a0909090909090909090941646d696e3c2f74643e0d0a0909090909090909093c2f74723e0d0a0d0a09090909090909093c2f7461626c653e0d0a0d0a09090909090909093c7461626c652077696474683d22353030222063656c6c70616464696e673d2230222063656c6c73706163696e673d22302220626f726465723d2230223e0d0a0d0a0d0a0909090909090909093c74723e0d0a090909090909090909093c74642077696474683d22313522206865696768743d2235223e3c2f74643e0d0a090909090909090909093c7464206865696768743d223235220d0a09090909090909090909097374796c653d22636f6c6f723a20233537353735373b20666f6e742d66616d696c793a20417269616c2c2048656c7665746963612c2073616e732d73657269663b20666f6e742d73697a653a20313370783b223e0d0a0d0a090909090909090909090d0a090909090909090909093c623e41636365737320496e666f726d6174696f6e3a3c2f623e3c2f74643e0d0a0909090909090909093c2f74723e0d0a0d0a0d0a0909090909090909093c74723e0d0a090909090909090909093c74642077696474683d22313522206865696768743d2235223e3c2f74643e0d0a090909090909090909093c7464206865696768743d223230220d0a09090909090909090909097374796c653d22636f6c6f723a20233537353735373b20666f6e742d66616d696c793a20417269616c2c2048656c7665746963612c2073616e732d73657269663b20666f6e742d73697a653a20313370783b223e0d0a090909090909090909090d0a0909090909090909090954656d706f726172792050617373776f72643a2038614536694732643c2f74643e0d0a0909090909090909093c2f74723e0d0a0d0a0909090909090909093c74723e0d0a090909090909090909093c74642077696474683d22313522206865696768743d2235223e3c2f74643e0d0a090909090909090909093c7464206865696768743d223330220d0a09090909090909090909097374796c653d22636f6c6f723a20233537353735373b20666f6e742d66616d696c793a20417269616c2c2048656c7665746963612c2073616e732d73657269663b20666f6e742d73697a653a20313370783b223e0d0a090909090909090909090d0a09090909090909090909466f6c6c6f772074686973206c696e6b20746f206163636573732074686520506f7274616c3a203c610d0a09090909090909090909097374796c653d22666f6e742d66616d696c793a20417269616c2c2048656c7665746963612c2073616e732d73657269663b20666f6e742d73697a653a20313370783b20636f6c6f723a2023353539626465220d0a0909090909090909090909687265663d2223223e687474703a2f2f6c6f63616c686f73742f7a696e6762616e672f3c2f613e3c2f74643e0d0a0909090909090909093c2f74723e0d0a0d0a09090909090909093c2f7461626c653e0d0a09090909090909093c2f74643e0d0a090909090909093c2f74723e0d0a0d0a0d0a0d0a090909090909090d0a0909090909093c2f7461626c653e0d0a0d0a0909090909093c2f74643e0d0a0909090909093c74642077696474683d223122206267636f6c6f723d2223623162316231223e3c2f74643e0d0a09090909093c2f74723e0d0a09090909093c74723e0d0a0909090909093c74642077696474683d223122206267636f6c6f723d2223623162316231223e3c2f74643e0d0a0909090909090d0a0909090909093c7464207374796c653d2270616464696e673a2030707820313070782030707820313070783b222076616c69676e3d226d6964646c65220d0a09090909090909616c69676e3d226c65667422206865696768743d223437223e0d0a0909090909093c700d0a090909090909097374796c653d22666f6e742d73697a653a20313170783b20666f6e742d66616d696c793a20417269616c2c2048656c7665746963612c2073616e732d73657269663b20636f6c6f723a20726762283130322c203130322c20313032293b20666f6e742d7765696768743a206e6f726d616c3b206d617267696e2d746f703a203570783b206d617267696e2d626f74746f6d3a203570783b20746578742d616c69676e3a206a757374696679223e446973636c61696d65723a3c62723e0d0a09090909090954686520696e666f726d6174696f6e20636f6e7461696e656420696e207468697320656c656374726f6e6963206d65737361676520616e6420616e790d0a0909090909096174746163686d656e747320746f2074686973206d6573736167652061726520696e74656e64656420666f7220746865206578636c757369766520757365206f660d0a0909090909097468652061646472657373656528732920616e64206d617920636f6e7461696e2070726f70726965746172792c20636f6e666964656e7469616c206f720d0a09090909090970726976696c6567656420696e666f726d6174696f6e2e20496620796f7520617265206e6f742074686520696e74656e64656420726563697069656e742c20796f750d0a09090909090973686f756c64206e6f742064697373656d696e6174652c2064697374726962757465206f7220636f7079207468697320652d6d61696c2e20506c656173650d0a09090909090964657374726f7920616c6c20636f70696573206f662074686973206d65737361676520616e6420616e79206174746163686d656e74732e200d0a0909090909093c2f703e0d0a0909090909093c2f74643e0d0a0909090909093c74642077696474683d223122206267636f6c6f723d2223623162316231223e3c2f74643e0d0a09090909093c2f74723e0d0a090909093c2f7461626c653e0d0a090909093c2f74643e0d0a0909093c2f74723e0d0a0d0a0d0a0d0a0d0a0d0a0d0a09093c2f7461626c653e0d0a09093c2f74643e0d0a093c2f74723e0d0a0d0a093c74723e0d0a09090d0a09093c74642077696474683d2235393622206865696768743d2237302220616c69676e3d226c656674220d0a0909097374796c653d226261636b67726f756e642d7265706561743a206e6f2d7265706561743b20666f6e742d73697a653a20313270783b20636f6c6f723a20233030303030303b20666f6e742d66616d696c793a20417269616c2c2048656c7665746963612c2073616e732d73657269663b220d0a0909096261636b67726f756e643d22687474703a2f2f6c6f63616c686f73742f7a696e6762616e672f2f7075626c69632f656d61696c496d616765732f65786163742d70656e742d636f6c6f72732d666f6f7465722e706e67223e0d0a09090d0a0d0a09093c7461626c6520626f726465723d2230222063656c6c70616464696e673d2230222063656c6c73706163696e673d2230222077696474683d22353830223e0d0a0909093c74723e0d0a090909093c74642077696474683d223135222076616c69676e3d22746f70223e3c2f74643e0d0a090909093c74642076616c69676e3d22746f70222077696474683d223635220d0a09090909097374796c653d22666f6e742d66616d696c793a20417269616c2c2048656c7665746963612c2073616e732d73657269663b20666f6e742d73697a653a20313070783b20666f6e742d7374796c653a206e6f726d616c3b20666f6e742d7765696768743a206e6f726d616c3b20636f6c6f723a20236666663b2070616464696e672d6c6566743a2033357078223e546869730d0a09090909646f63756d656e7420616e642074686520696e666f726d6174696f6e20636f6e7461696e6564207468657265696e2c206973207468652070726f70726965746172790d0a09090909616e6420636f6e666964656e7469616c20696e666f726d6174696f6e3c2f74643e0d0a0909093c2f74723e0d0a0d0a0909093c74723e0d0a090909093c74643e3c2f74643e0d0a090909093c74642077696474683d223830220d0a09090909097374796c653d22666f6e742d66616d696c793a20417269616c2c2048656c7665746963612c2073616e732d73657269663b20666f6e742d73697a653a20313070783b20666f6e742d7374796c653a206e6f726d616c3b20666f6e742d7765696768743a206e6f726d616c3b20636f6c6f723a20236666663b20746578742d616c69676e3a206a7573746966793b2070616464696e672d6c6566743a20343270783b223e6f660d0a090909094765744c696e632c20496e632e20616e642074686520646f63756d656e742c20616e642074686520696e666f726d6174696f6e0d0a09090909636f6e7461696e6564207468657265696e2c206d6179206e6f742062653c2f74643e0d0a0909093c2f74723e0d0a0d0a0909093c74723e0d0a090909093c74643e3c2f74643e0d0a090909093c74642077696474683d223830220d0a09090909097374796c653d22666f6e742d66616d696c793a20417269616c2c2048656c7665746963612c2073616e732d73657269663b20666f6e742d73697a653a20313070783b20666f6e742d7374796c653a206e6f726d616c3b20666f6e742d7765696768743a206e6f726d616c3b20636f6c6f723a20236666663b2070616464696e672d6c6566743a2034347078223e757365642c0d0a09090909636f706965642c206f7220646973636c6f73656420776974686f7574207468652065787072657373207072696f72207772697474656e20636f6e73656e74206f660d0a090909094765744c696e632c20496e632e3c2f74643e0d0a0909093c2f74723e0d0a0d0a0909093c74723e0d0a090909093c74643e3c2f74643e0d0a090909093c74642077696474683d223830220d0a09090909097374796c653d22666f6e742d66616d696c793a20417269616c2c2048656c7665746963612c2073616e732d73657269663b20666f6e742d73697a653a20313070783b20666f6e742d7374796c653a206e6f726d616c3b20666f6e742d7765696768743a20626f6c643b20636f6c6f723a20236666663b2070616464696e672d6c6566743a203133357078223e26233136390d0a0909090932303133204765744c696e632c20496e632e20416c6c207269676874732072657365727665642e3c2f74643e0d0a0909093c2f74723e0d0a09093c2f7461626c653e0d0a0d0a09093c2f74643e0d0a0d0a09090d0a0d0a093c2f74723e0d0a0d0a3c2f7461626c653e0d0a3c2f626f64793e0d0a3c2f68746d6c3e, 1, 1, '2013-06-02 14:26:10', '2013-06-02 08:56:10', NULL, 1, NULL, NULL);
INSERT INTO `apmmailqueue` (`mailqueueid`, `emailfrom`, `emailto`, `emailsubject`, `body`, `mailstatus`, `referenceid`, `createddatetime`, `updateddatetime`, `deleteddatetime`, `statusid`, `createdby`, `lastupdatedby`) VALUES
(28, 'support@getlinc.com', 'merchantadmin1@gmail.com', 'New User Account - Username', 0x3c21444f43545950452068746d6c205055424c494320222d2f2f5733432f2f445444205848544d4c20312e30205472616e736974696f6e616c2f2f454e222022687474703a2f2f7777772e77332e6f72672f54522f7868746d6c312f4454442f7868746d6c312d7472616e736974696f6e616c2e647464223e0d0a3c68746d6c20786d6c6e733d22687474703a2f2f7777772e77332e6f72672f313939392f7868746d6c220d0a09786d6c6e733a763d2275726e3a736368656d61732d6d6963726f736f66742d636f6d3a766d6c223e0d0a3c686561643e0d0a3c6d65746120687474702d65717569763d22436f6e74656e742d547970652220636f6e74656e743d22746578742f68746d6c3b20636861727365743d7574662d3822202f3e0d0a3c6d657461206e616d653d22534b5950455f544f4f4c4241522220636f6e74656e743d22534b5950455f544f4f4c4241525f5041525345525f434f4d50415449424c4522202f3e0d0a3c7469746c653e4765744c696e632040204e65772055736572204163636f756e7420557365726e616d6520437265617465643c2f7469746c653e0d0a3c7374796c6520747970653d22746578742f637373223e0d0a763a2a207b0d0a096265686176696f723a2075726c282364656661756c7423564d4c293b0d0a09646973706c61793a20696e6c696e652d626c6f636b0d0a7d0d0a3c2f7374796c653e0d0a3c2f686561643e0d0a3c626f64793e0d0a3c7461626c652077696474683d223539342220626f726465723d2230222063656c6c70616464696e673d2230222063656c6c73706163696e673d2230223e0d0a0d0a0d0a093c74723e0d0a09093c74643e0d0a09093c7461626c652077696474683d2231303025222063656c6c70616464696e673d2230222063656c6c73706163696e673d2230223e0d0a0909093c74723e0d0a090909093c74642076616c69676e3d22746f70220d0a09090909097374796c653d22666f6e742d73697a653a20313270783b20636f6c6f723a20233030303030303b206c696e652d6865696768743a20313530253b20666f6e742d66616d696c793a2056657264616e612c2047656e6576612c2073616e732d73657269663b223e0d0a0d0a090909093c7461626c652077696474683d22353936222063656c6c70616464696e673d2230222063656c6c73706163696e673d2230223e0d0a0d0a0d0a09090909093c74723e0d0a0909090909093c74642076616c69676e3d22746f70220d0a090909090909097374796c653d22666f6e742d73697a653a20313270783b20636f6c6f723a20233030303030303b206c696e652d6865696768743a20313530253b20666f6e742d66616d696c793a2056657264616e612c2047656e6576612c2073616e732d73657269663b223e0d0a0d0a0909090909093c7461626c652077696474683d22353936222063656c6c70616464696e673d2230222063656c6c73706163696e673d2230223e0d0a0d0a0d0a090909090909093c74723e0d0a09090909090909090d0a09090909090909093c74642077696474683d2235393622206865696768743d2238362220616c69676e3d226c656674220d0a0909090909090909097374796c653d22666f6e742d73697a653a20313270783b20636f6c6f723a20233030303030303b220d0a0909090909090909096261636b67726f756e643d2223736974656261736575726c2f7075626c69632f656d61696c496d616765732f65786163742d70656e742d636f6c6f72732d6865616465722e6a7067223e0d0a09090909090909090d0a09090909090909093c7461626c652063656c6c70616464696e673d2230222063656c6c73706163696e673d22302220626f726465723d2230222077696474683d22353830223e0d0a0909090909090909093c74723e0d0a090909090909090909093c74642077696474683d223135223e3c2f74643e0d0a090909090909090909090d0a090909090909090909093c74642076616c69676e3d22746f70220d0a09090909090909090909097374796c653d22746578742d616c69676e3a206c6566743b20766572746963616c2d616c69676e3a20746f703b223e3c696d670d0a0909090909090909090909616c69676e3d226d6964646c6522207374796c653d22766572746963616c2d616c69676e3a206d6964646c653b2220626f726465723d2230220d0a09090909090909090909097372633d2223736974656261736575726c2f7075626c69632f656d61696c496d616765732f70656e742d6c6f676f2d736d616c6c312e706e67220d0a0909090909090909090909616c743d224765744c696e6322202f3e3c2f74643e0d0a090909090909090909093c74642077696474683d223730223e3c2f74643e0d0a090909090909090909093c74642077696474683d223135223e3c2f74643e0d0a0909090909090909093c2f74723e0d0a09090909090909093c2f7461626c653e0d0a0d0a0d0a09090909090909093c2f74643e0d0a090909090909093c2f74723e0d0a0d0a0909090909093c2f7461626c653e0d0a0909090909093c2f74643e0d0a09090909093c2f74723e0d0a0d0a090909093c2f7461626c653e0d0a090909093c2f74643e0d0a0909093c2f74723e0d0a0d0a0d0a0d0a0909093c212d2d626f6479202d2d3e0d0a0d0a0909093c74723e0d0a090909093c74643e0d0a090909093c7461626c652077696474683d223539362220626f726465723d2230222063656c6c70616464696e673d2230222063656c6c73706163696e673d2230223e0d0a09090909093c74723e0909090909090d0a0909090909093c74642077696474683d223122206267636f6c6f723d2223623162316231223e3c2f74643e0d0a0909090909093c74643e0d0a0909090909093c7461626c652077696474683d223539342220616c69676e3d2263656e7465722220626f726465723d2230222063656c6c73706163696e673d2230223e0d0a0d0a090909090909093c74723e0d0a09090909090909093c7464207374796c653d226865696768743a203570783b223e3c2f74643e0d0a090909090909093c2f74723e0d0a090909090909093c74723e0d0a09090909090909093c7464206865696768743d223230220d0a0909090909090909097374796c653d22746578742d616c69676e3a2063656e7465723b20666f6e742d73697a653a20313570783b20666f6e742d66616d696c793a20417269616c2c2048656c7665746963612c2073616e732d73657269663b220d0a090909090909090909616c69676e3d2263656e746572223e3c7374726f6e673e4765744c696e633c2f7374726f6e673e3c2f74643e0d0a090909090909093c2f74723e0d0a090909090909093c74723e0d0a09090909090909093c7464206865696768743d223230220d0a0909090909090909097374796c653d22746578742d616c69676e3a2063656e7465723b20666f6e742d73697a653a20313570783b20666f6e742d66616d696c793a20417269616c2c2048656c7665746963612c2073616e732d73657269663b20626f726465722d626f74746f6d2d636f6c6f723a20236364636463643b20626f726465722d626f74746f6d2d7374796c653a20736f6c69643b20626f726465722d626f74746f6d2d77696474683a203270783b220d0a090909090909090909616c69676e3d2263656e746572223e3c7374726f6e673e4e65772055736572204163636f756e74202d0d0a0909090909090909557365726e616d653c2f7374726f6e673e3c2f74643e0d0a090909090909093c2f74723e0d0a0d0a090909090909093c74723e0d0a0d0a09090909090909093c7464206267636f6c6f723d2223464646464646222076616c69676e3d22746f70222077696474683d22353935220d0a0909090909090909097374796c653d22666f6e742d73697a653a20313370783b20666f6e742d7765696768743a206e6f726d616c3b20636f6c6f723a20233537353735373b20666f6e742d66616d696c793a20617269616c3b206c696e652d6865696768743a20313530253b223e0d0a09090909090909093c7461626c652077696474683d22353930222063656c6c70616464696e673d2230222063656c6c73706163696e673d2230223e0d0a0d0a0909090909090909093c74723e0d0a090909090909090909093c74642077696474683d22313522206865696768743d2232223e3c2f74643e0d0a090909090909090909093c74643e3c2f74643e0d0a0909090909090909093c2f74723e0d0a0909090909090909093c74723e0d0a090909090909090909093c74642077696474683d22313522206865696768743d2235223e3c2f74643e0d0a090909090909090909093c74640d0a09090909090909090909097374796c653d22636f6c6f723a20233537353735373b20666f6e742d66616d696c793a20417269616c2c2048656c7665746963612c2073616e732d73657269663b20666f6e742d73697a653a20313370783b223e4a756e652030322c20323031333c2f74643e0d0a0909090909090909093c2f74723e0d0a0909090909090909093c74723e0d0a090909090909090909093c7464206865696768743d223130223e3c2f74643e0d0a0909090909090909093c2f74723e0d0a0d0a0909090909090909093c74723e0d0a090909090909090909093c74642077696474683d22313522206865696768743d2235223e3c2f74643e0d0a090909090909090909093c74640d0a09090909090909090909097374796c653d22666f6e742d66616d696c793a20417269616c2c2048656c7665746963612c2073616e732d73657269663b20666f6e742d73697a653a20313370783b20636f6c6f723a2023353735373537223e5265666572656e63653a0d0a090909090909090909093c656d3e4d65726368616e742041646d696e204f6e653c2f656d3e3c2f74643e0d0a090909090909090909090d0a0909090909090909093c2f74723e0d0a0909090909090909093c74723e0d0a090909090909090909093c7464206865696768743d2238223e3c2f74643e0d0a0909090909090909093c2f74723e0d0a0d0a0909090909090909093c74723e0d0a090909090909090909093c74642077696474683d22313522206865696768743d2235223e3c2f74643e0d0a090909090909090909093c74640d0a09090909090909090909097374796c653d22636f6c6f723a20233537353735373b20666f6e742d66616d696c793a20417269616c2c2048656c7665746963612c2073616e732d73657269663b20666f6e742d73697a653a20313370783b2070616464696e672d746f703a203570783b223e3c623e57656c636f6d65213c2f623e0d0a09090909090909090909416e204163636f756e7420686173206265656e206372656174656420666f7220796f7520746f206163636573732074686520506f7274616c2e3c2f74643e0d0a0909090909090909093c2f74723e0d0a0d0a0909090909090909093c74723e0d0a090909090909090909093c74642077696474683d22313522206865696768743d2235223e3c2f74643e0d0a090909090909090909093c74640d0a09090909090909090909097374796c653d22636f6c6f723a20233537353735373b20666f6e742d66616d696c793a20417269616c2c2048656c7665746963612c2073616e732d73657269663b20666f6e742d73697a653a20313370783b2070616464696e672d746f703a203070783b223e44657461696c730d0a090909090909090909096f6620796f7572206163636f756e7420616e642061636365737320696e666f726d6174696f6e20617265206c69737465642062656c6f772e3c2f74643e0d0a0909090909090909093c2f74723e0d0a0d0a0d0a0d0a0909090909090909093c74723e0d0a090909090909090909093c7464206865696768743d2238223e3c2f74643e0d0a0909090909090909093c2f74723e0d0a0909090909090909093c74723e0d0a090909090909090909093c74642077696474683d22313522206865696768743d2235223e3c2f74643e0d0a090909090909090909093c74640d0a09090909090909090909097374796c653d22636f6c6f723a20233537353735373b20666f6e742d66616d696c793a20417269616c2c2048656c7665746963612c2073616e732d73657269663b20666f6e742d73697a653a20313370783b2070616464696e672d746f703a203570783b223e0d0a09090909090909090909506c6561736520636f6e7461637420796f75722053797374656d2041646d696e6973747261746f72207769746820616e79207175657374696f6e732e3c2f74643e0d0a0909090909090909093c2f74723e0d0a0d0a0909090909090909093c74723e0d0a090909090909090909093c7464206865696768743d2238223e3c2f74643e0d0a0909090909090909093c2f74723e0d0a0d0a09090909090909093c2f7461626c653e0d0a09090909090909093c2f74643e0d0a0d0a090909090909093c2f74723e0d0a0d0a090909090909093c74723e0d0a09090909090909090d0a09090909090909093c746420616c69676e3d226c656674222076616c69676e3d226d6964646c65220d0a0909090909090909097374796c653d22626f726465722d746f703a20233636362031707820736f6c69643b20626f726465722d626f74746f6d3a20233636362031707820736f6c69643b20666f6e742d73697a653a20313270783b20636f6c6f723a20233537353735373b20666f6e742d66616d696c793a20417269616c2c2048656c7665746963612c2073616e732d73657269663b223e0d0a09090909090909093c7461626c652077696474683d22353030222063656c6c70616464696e673d2230222063656c6c73706163696e673d22302220626f726465723d2230223e0d0a0d0a0d0a0909090909090909093c74723e0d0a090909090909090909093c74642077696474683d22313522206865696768743d2235223e3c2f74643e0d0a090909090909090909093c7464206865696768743d223235220d0a09090909090909090909097374796c653d22636f6c6f723a20233537353735373b20666f6e742d66616d696c793a20417269616c2c2048656c7665746963612c2073616e732d73657269663b20666f6e742d73697a653a20313370783b223e0d0a0d0a090909090909090909090d0a090909090909090909093c623e4163636f756e7420496e666f726d6174696f6e3a203c2f623e3c2f74643e0d0a0909090909090909093c2f74723e0d0a0d0a0d0a0909090909090909093c74723e0d0a090909090909090909093c74642077696474683d22313522206865696768743d2235223e3c2f74643e0d0a090909090909090909093c7464206865696768743d223230220d0a09090909090909090909097374796c653d22636f6c6f723a20233537353735373b20666f6e742d66616d696c793a20417269616c2c2048656c7665746963612c2073616e732d73657269663b20666f6e742d73697a653a20313370783b223e0d0a090909090909090909090d0a090909090909090909094669727374204e616d653a204d65726368616e742041646d696e3c2f74643e0d0a0909090909090909093c2f74723e0d0a0d0a0909090909090909093c74723e0d0a090909090909090909093c74642077696474683d22313522206865696768743d2235223e3c2f74643e0d0a090909090909090909093c7464206865696768743d223230220d0a09090909090909090909097374796c653d22636f6c6f723a20233537353735373b20666f6e742d66616d696c793a20417269616c2c2048656c7665746963612c2073616e732d73657269663b20666f6e742d73697a653a20313370783b223e4c6173740d0a090909090909090909094e616d653a204f6e653c2f74643e0d0a0909090909090909093c2f74723e0d0a0d0a0909090909090909093c74723e0d0a090909090909090909093c74642077696474683d22313522206865696768743d2235223e3c2f74643e0d0a090909090909090909093c7464206865696768743d223230220d0a09090909090909090909097374796c653d22636f6c6f723a20233537353735373b20666f6e742d66616d696c793a20417269616c2c2048656c7665746963612c2073616e732d73657269663b20666f6e742d73697a653a20313370783b223e526f6c653a0d0a090909090909090909094d65726368616e7441646d696e3c2f74643e0d0a0909090909090909093c2f74723e0d0a0d0a09090909090909093c2f7461626c653e0d0a0d0a09090909090909093c7461626c652077696474683d22353030222063656c6c70616464696e673d2230222063656c6c73706163696e673d22302220626f726465723d2230223e0d0a0d0a0d0a0909090909090909093c74723e0d0a090909090909090909093c74642077696474683d22313522206865696768743d2235223e3c2f74643e0d0a090909090909090909093c7464206865696768743d223235220d0a09090909090909090909097374796c653d22636f6c6f723a20233537353735373b20666f6e742d66616d696c793a20417269616c2c2048656c7665746963612c2073616e732d73657269663b20666f6e742d73697a653a20313370783b223e0d0a0d0a090909090909090909090d0a090909090909090909093c623e41636365737320496e666f726d6174696f6e3a3c2f623e3c2f74643e0d0a0909090909090909093c2f74723e0d0a0d0a0d0a0909090909090909093c74723e0d0a090909090909090909093c74642077696474683d22313522206865696768743d2235223e3c2f74643e0d0a090909090909090909093c7464206865696768743d223230220d0a09090909090909090909097374796c653d22636f6c6f723a20233537353735373b20666f6e742d66616d696c793a20417269616c2c2048656c7665746963612c2073616e732d73657269663b20666f6e742d73697a653a20313370783b223e0d0a090909090909090909090d0a09090909090909090909557365726e616d653a206d65726368616e7461646d696e3140676d61696c2e636f6d3c2f74643e0d0a0909090909090909093c2f74723e0d0a0d0a0909090909090909093c74723e0d0a090909090909090909093c74642077696474683d22313522206865696768743d2235223e3c2f74643e0d0a090909090909090909093c7464206865696768743d223330220d0a09090909090909090909097374796c653d22636f6c6f723a20233537353735373b20666f6e742d66616d696c793a20417269616c2c2048656c7665746963612c2073616e732d73657269663b20666f6e742d73697a653a20313370783b223e0d0a090909090909090909090d0a090909090909090909093c656d3e596f75722074656d706f726172792070617373776f72642077696c6c2062652073656e7420696e20612073657061726174650d0a09090909090909090909656d61696c2e203c2f656d3e3c2f74643e0d0a0909090909090909093c2f74723e0d0a0d0a09090909090909093c2f7461626c653e0d0a09090909090909093c2f74643e0d0a090909090909093c2f74723e0d0a0d0a0d0a0d0a090909090909090d0a0909090909093c2f7461626c653e0d0a0d0a0909090909093c2f74643e0d0a0909090909093c74642077696474683d223122206267636f6c6f723d2223623162316231223e3c2f74643e0d0a09090909093c2f74723e0d0a09090909093c74723e0d0a0909090909093c74642077696474683d223122206267636f6c6f723d2223623162316231223e3c2f74643e0d0a0d0a0909090909090d0a0909090909093c7464207374796c653d2270616464696e673a2030707820313070782030707820313070783b222076616c69676e3d226d6964646c65220d0a09090909090909616c69676e3d226c65667422206865696768743d223437223e0d0a0909090909093c700d0a090909090909097374796c653d22666f6e742d73697a653a20313170783b20666f6e742d66616d696c793a20417269616c2c2048656c7665746963612c2073616e732d73657269663b20636f6c6f723a20726762283130322c203130322c20313032293b20666f6e742d7765696768743a206e6f726d616c3b206d617267696e2d746f703a203570783b206d617267696e2d626f74746f6d3a203570783b20746578742d616c69676e3a206a757374696679223e446973636c61696d65723a3c62723e0d0a09090909090954686520696e666f726d6174696f6e20636f6e7461696e656420696e207468697320656c656374726f6e6963206d65737361676520616e6420616e790d0a0909090909096174746163686d656e747320746f2074686973206d6573736167652061726520696e74656e64656420666f7220746865206578636c757369766520757365206f660d0a0909090909097468652061646472657373656528732920616e64206d617920636f6e7461696e2070726f70726965746172792c20636f6e666964656e7469616c206f720d0a09090909090970726976696c6567656420696e666f726d6174696f6e2e20496620796f7520617265206e6f742074686520696e74656e64656420726563697069656e742c20796f750d0a09090909090973686f756c64206e6f742064697373656d696e6174652c2064697374726962757465206f7220636f7079207468697320652d6d61696c2e20506c656173650d0a09090909090964657374726f7920616c6c20636f70696573206f662074686973206d65737361676520616e6420616e79206174746163686d656e74732e200d0a0909090909093c2f703e0d0a0909090909093c2f74643e0d0a0909090909093c74642077696474683d223122206267636f6c6f723d2223623162316231223e3c2f74643e0d0a09090909093c2f74723e0d0a090909093c2f7461626c653e0d0a090909093c2f74643e0d0a0909093c2f74723e0d0a0d0a0d0a0d0a0d0a0d0a0d0a09093c2f7461626c653e0d0a09093c2f74643e0d0a093c2f74723e0d0a0d0a093c74723e0d0a09090d0a09093c74642077696474683d2235393622206865696768743d2237302220616c69676e3d226c656674220d0a0909097374796c653d226261636b67726f756e642d7265706561743a206e6f2d7265706561743b20666f6e742d73697a653a20313270783b20636f6c6f723a20233030303030303b20666f6e742d66616d696c793a20417269616c2c2048656c7665746963612c2073616e732d73657269663b220d0a0909096261636b67726f756e643d2223736974656261736575726c2f7075626c69632f656d61696c496d616765732f65786163742d70656e742d636f6c6f72732d666f6f7465722e706e67223e0d0a09090d0a0d0a09093c7461626c6520626f726465723d2230222063656c6c70616464696e673d2230222063656c6c73706163696e673d2230222077696474683d22353830223e0d0a0909093c74723e0d0a090909093c74642077696474683d223135222076616c69676e3d22746f70223e3c2f74643e0d0a090909093c74642076616c69676e3d22746f70222077696474683d223635220d0a09090909097374796c653d22666f6e742d66616d696c793a20417269616c2c2048656c7665746963612c2073616e732d73657269663b20666f6e742d73697a653a20313070783b20666f6e742d7374796c653a206e6f726d616c3b20666f6e742d7765696768743a206e6f726d616c3b20636f6c6f723a20236666663b2070616464696e672d6c6566743a2033357078223e546869730d0a09090909646f63756d656e7420616e642074686520696e666f726d6174696f6e20636f6e7461696e6564207468657265696e2c206973207468652070726f70726965746172790d0a09090909616e6420636f6e666964656e7469616c20696e666f726d6174696f6e3c2f74643e0d0a0909093c2f74723e0d0a0d0a0909093c74723e0d0a090909093c74643e3c2f74643e0d0a090909093c74642077696474683d223830220d0a09090909097374796c653d22666f6e742d66616d696c793a20417269616c2c2048656c7665746963612c2073616e732d73657269663b20666f6e742d73697a653a20313070783b20666f6e742d7374796c653a206e6f726d616c3b20666f6e742d7765696768743a206e6f726d616c3b20636f6c6f723a20236666663b20746578742d616c69676e3a206a7573746966793b2070616464696e672d6c6566743a20343270783b223e6f660d0a090909094765744c696e632c20496e632e20616e642074686520646f63756d656e742c20616e642074686520696e666f726d6174696f6e0d0a09090909636f6e7461696e6564207468657265696e2c206d6179206e6f742062653c2f74643e0d0a0909093c2f74723e0d0a0d0a0909093c74723e0d0a090909093c74643e3c2f74643e0d0a090909093c74642077696474683d223830220d0a09090909097374796c653d22666f6e742d66616d696c793a20417269616c2c2048656c7665746963612c2073616e732d73657269663b20666f6e742d73697a653a20313070783b20666f6e742d7374796c653a206e6f726d616c3b20666f6e742d7765696768743a206e6f726d616c3b20636f6c6f723a20236666663b2070616464696e672d6c6566743a2034347078223e757365642c0d0a09090909636f706965642c206f7220646973636c6f73656420776974686f7574207468652065787072657373207072696f72207772697474656e20636f6e73656e74206f660d0a090909094765744c696e632c20496e632e3c2f74643e0d0a0909093c2f74723e0d0a0d0a0909093c74723e0d0a090909093c74643e3c2f74643e0d0a090909093c74642077696474683d223830220d0a09090909097374796c653d22666f6e742d66616d696c793a20417269616c2c2048656c7665746963612c2073616e732d73657269663b20666f6e742d73697a653a20313070783b20666f6e742d7374796c653a206e6f726d616c3b20666f6e742d7765696768743a20626f6c643b20636f6c6f723a20236666663b2070616464696e672d6c6566743a203133357078223e26233136390d0a0909090932303133204765744c696e632c20496e632e20416c6c207269676874732072657365727665642e3c2f74643e0d0a0909093c2f74723e0d0a09093c2f7461626c653e0d0a0d0a09093c2f74643e0d0a0d0a09090d0a0d0a093c2f74723e0d0a0d0a3c2f7461626c653e0d0a3c2f626f64793e0d0a3c2f68746d6c3e, 1, NULL, '2013-06-02 15:15:54', '2013-06-02 09:45:54', NULL, 1, NULL, NULL),
(29, 'support@getlinc.com', 'merchantadmin1@gmail.com', 'New User Account - Temporary Password', 0x3c21444f43545950452068746d6c205055424c494320222d2f2f5733432f2f445444205848544d4c20312e30205472616e736974696f6e616c2f2f454e222022687474703a2f2f7777772e77332e6f72672f54522f7868746d6c312f4454442f7868746d6c312d7472616e736974696f6e616c2e647464223e0d0a3c68746d6c20786d6c6e733d22687474703a2f2f7777772e77332e6f72672f313939392f7868746d6c220d0a09786d6c6e733a763d2275726e3a736368656d61732d6d6963726f736f66742d636f6d3a766d6c223e0d0a3c686561643e0d0a3c6d65746120687474702d65717569763d22436f6e74656e742d547970652220636f6e74656e743d22746578742f68746d6c3b20636861727365743d7574662d3822202f3e0d0a3c6d657461206e616d653d22534b5950455f544f4f4c4241522220636f6e74656e743d22534b5950455f544f4f4c4241525f5041525345525f434f4d50415449424c4522202f3e0d0a3c7469746c653e4765744c696e632040204e65772055736572204163636f756e742054656d702050617373776f726420437265617465643c2f7469746c653e0d0a3c7374796c6520747970653d22746578742f637373223e0d0a763a2a207b0d0a096265686176696f723a2075726c282364656661756c7423564d4c293b0d0a09646973706c61793a20696e6c696e652d626c6f636b0d0a7d0d0a3c2f7374796c653e0d0a3c2f686561643e0d0a3c626f64793e0d0a3c7461626c652077696474683d223539342220626f726465723d2230222063656c6c70616464696e673d2230222063656c6c73706163696e673d2230223e0d0a0d0a0d0a093c74723e0d0a09093c74643e0d0a09093c7461626c652077696474683d2231303025222063656c6c70616464696e673d2230222063656c6c73706163696e673d2230223e0d0a0909093c74723e0d0a090909093c74642076616c69676e3d22746f70220d0a09090909097374796c653d22666f6e742d73697a653a20313270783b20636f6c6f723a20233030303030303b206c696e652d6865696768743a20313530253b20666f6e742d66616d696c793a2056657264616e612c2047656e6576612c2073616e732d73657269663b223e0d0a0d0a090909093c7461626c652077696474683d22353936222063656c6c70616464696e673d2230222063656c6c73706163696e673d2230223e0d0a0d0a0d0a09090909093c74723e0d0a0909090909093c74642076616c69676e3d22746f70220d0a090909090909097374796c653d22666f6e742d73697a653a20313270783b20636f6c6f723a20233030303030303b206c696e652d6865696768743a20313530253b20666f6e742d66616d696c793a2056657264616e612c2047656e6576612c2073616e732d73657269663b223e0d0a0d0a0909090909093c7461626c652077696474683d22353936222063656c6c70616464696e673d2230222063656c6c73706163696e673d2230223e0d0a0d0a0d0a090909090909093c74723e0d0a09090909090909090d0a09090909090909093c74642077696474683d2235393622206865696768743d2238362220616c69676e3d226c656674220d0a0909090909090909097374796c653d22666f6e742d73697a653a20313270783b20636f6c6f723a20233030303030303b220d0a0909090909090909096261636b67726f756e643d22687474703a2f2f6c6f63616c686f73742f7a696e6762616e672f2f7075626c69632f656d61696c496d616765732f65786163742d70656e742d636f6c6f72732d6865616465722e6a7067223e0d0a09090909090909090d0a09090909090909093c7461626c652063656c6c70616464696e673d2230222063656c6c73706163696e673d22302220626f726465723d2230222077696474683d22353830223e0d0a0909090909090909093c74723e0d0a090909090909090909093c74642077696474683d223135223e3c2f74643e090909090909090909090d0a090909090909090909093c74642076616c69676e3d22746f70220d0a09090909090909090909097374796c653d22746578742d616c69676e3a206c6566743b20766572746963616c2d616c69676e3a20746f703b223e3c696d670d0a0909090909090909090909616c69676e3d226d6964646c6522207374796c653d22766572746963616c2d616c69676e3a206d6964646c653b2220626f726465723d2230220d0a09090909090909090909097372633d22687474703a2f2f6c6f63616c686f73742f7a696e6762616e672f2f7075626c69632f656d61696c496d616765732f70656e742d6c6f676f2d736d616c6c312e706e67220d0a0909090909090909090909616c743d224765744c696e6322202f3e3c2f74643e0d0a090909090909090909093c74642077696474683d223730223e3c2f74643e0d0a090909090909090909093c74642077696474683d223135223e3c2f74643e0d0a0909090909090909093c2f74723e0d0a09090909090909093c2f7461626c653e0d0a0d0a0d0a09090909090909093c2f74643e0d0a090909090909093c2f74723e0d0a0d0a0909090909093c2f7461626c653e0d0a0909090909093c2f74643e0d0a09090909093c2f74723e0d0a0d0a090909093c2f7461626c653e0d0a090909093c2f74643e0d0a0909093c2f74723e0d0a0d0a0d0a0d0a0909093c212d2d626f6479202d2d3e0d0a0d0a0909093c74723e0d0a090909093c74643e0d0a090909093c7461626c652077696474683d223539362220626f726465723d2230222063656c6c70616464696e673d2230222063656c6c73706163696e673d2230223e0d0a09090909093c74723e0909090909090d0a0909090909093c74642077696474683d223122206267636f6c6f723d2223623162316231223e3c2f74643e0d0a0909090909093c74643e0d0a0909090909093c7461626c652077696474683d223539342220616c69676e3d2263656e7465722220626f726465723d2230222063656c6c73706163696e673d2230223e0d0a0d0a090909090909093c74723e0d0a09090909090909093c7464207374796c653d226865696768743a203570783b223e3c2f74643e0d0a090909090909093c2f74723e0d0a090909090909093c74723e0d0a09090909090909093c7464206865696768743d223230220d0a0909090909090909097374796c653d22746578742d616c69676e3a2063656e7465723b20666f6e742d73697a653a20313570783b20666f6e742d66616d696c793a20417269616c2c2048656c7665746963612c2073616e732d73657269663b220d0a090909090909090909616c69676e3d2263656e746572223e3c7374726f6e673e4765744c696e633c2f7374726f6e673e3c2f74643e0d0a090909090909093c2f74723e0d0a090909090909093c74723e0d0a09090909090909093c7464206865696768743d223230220d0a0909090909090909097374796c653d22746578742d616c69676e3a2063656e7465723b20666f6e742d73697a653a20313570783b20666f6e742d66616d696c793a20417269616c2c2048656c7665746963612c2073616e732d73657269663b20626f726465722d626f74746f6d2d636f6c6f723a20236364636463643b20626f726465722d626f74746f6d2d7374796c653a20736f6c69643b20626f726465722d626f74746f6d2d77696474683a203270783b220d0a090909090909090909616c69676e3d2263656e746572223e3c7374726f6e673e4e65772055736572204163636f756e74202d0d0a090909090909090954656d706f726172792050617373776f72643c2f7374726f6e673e3c2f74643e0d0a090909090909093c2f74723e0d0a0d0a090909090909093c74723e0d0a0d0a09090909090909093c7464206267636f6c6f723d2223464646464646222076616c69676e3d22746f70222077696474683d22353935220d0a0909090909090909097374796c653d22666f6e742d73697a653a20313370783b20666f6e742d7765696768743a206e6f726d616c3b20636f6c6f723a20233537353735373b20666f6e742d66616d696c793a20617269616c3b206c696e652d6865696768743a20313530253b223e0d0a09090909090909093c7461626c652077696474683d22353930222063656c6c70616464696e673d2230222063656c6c73706163696e673d2230223e0d0a0d0a0909090909090909093c74723e0d0a090909090909090909093c74642077696474683d22313522206865696768743d2232223e3c2f74643e0d0a090909090909090909093c74643e3c2f74643e0d0a0909090909090909093c2f74723e0d0a0909090909090909093c74723e0d0a090909090909090909093c74642077696474683d22313522206865696768743d2235223e3c2f74643e0d0a090909090909090909093c74640d0a09090909090909090909097374796c653d22636f6c6f723a20233537353735373b20666f6e742d66616d696c793a20417269616c2c2048656c7665746963612c2073616e732d73657269663b20666f6e742d73697a653a20313370783b223e4a756e652030322c20323031333c2f74643e0d0a0909090909090909093c2f74723e0d0a0909090909090909093c74723e0d0a090909090909090909093c7464206865696768743d223130223e3c2f74643e0d0a0909090909090909093c2f74723e0d0a0d0a0909090909090909093c74723e0d0a090909090909090909093c74642077696474683d22313522206865696768743d2235223e3c2f74643e0d0a090909090909090909093c74640d0a09090909090909090909097374796c653d22666f6e742d66616d696c793a20417269616c2c2048656c7665746963612c2073616e732d73657269663b20666f6e742d73697a653a20313370783b20636f6c6f723a2023353735373537223e5265666572656e63653a0d0a090909090909090909093c656d3e4d65726368616e742041646d696e204f6e65203c2f656d3e3c2f74643e0d0a090909090909090909093c212d2d636f6c6f723a233263613366353b202d2d3e0d0a0909090909090909093c2f74723e0d0a0909090909090909093c74723e0d0a090909090909090909093c7464206865696768743d2238223e3c2f74643e0d0a0909090909090909093c2f74723e0d0a0d0a0909090909090909093c74723e0d0a090909090909090909093c74642077696474683d22313522206865696768743d2235223e3c2f74643e0d0a090909090909090909093c74640d0a09090909090909090909097374796c653d22636f6c6f723a20233537353735373b20666f6e742d66616d696c793a20417269616c2c2048656c7665746963612c2073616e732d73657269663b20666f6e742d73697a653a20313370783b2070616464696e672d746f703a203570783b223e3c623e57656c636f6d65213c2f623e0d0a09090909090909090909416e204163636f756e7420686173206265656e206372656174656420666f7220796f7520746f206163636573732074686520506f7274616c2e3c2f74643e0d0a0909090909090909093c2f74723e0d0a0d0a0909090909090909093c74723e0d0a090909090909090909093c74642077696474683d22313522206865696768743d2235223e3c2f74643e0d0a090909090909090909093c74640d0a09090909090909090909097374796c653d22636f6c6f723a20233537353735373b20666f6e742d66616d696c793a20417269616c2c2048656c7665746963612c2073616e732d73657269663b20666f6e742d73697a653a20313370783b2070616464696e672d746f703a203070783b223e44657461696c730d0a090909090909090909096f6620796f7572206163636f756e7420616e642061636365737320696e666f726d6174696f6e20617265206c69737465642062656c6f772e3c2f74643e0d0a0909090909090909093c2f74723e0d0a0d0a0d0a0d0a0909090909090909093c74723e0d0a090909090909090909093c7464206865696768743d2238223e3c2f74643e0d0a0909090909090909093c2f74723e0d0a0909090909090909093c74723e0d0a090909090909090909093c74642077696474683d22313522206865696768743d2235223e3c2f74643e0d0a090909090909090909093c74640d0a09090909090909090909097374796c653d22636f6c6f723a20233537353735373b20666f6e742d66616d696c793a20417269616c2c2048656c7665746963612c2073616e732d73657269663b20666f6e742d73697a653a20313370783b2070616464696e672d746f703a203570783b223e0d0a09090909090909090909506c6561736520636f6e7461637420796f75722053797374656d2041646d696e6973747261746f72207769746820616e79207175657374696f6e732e3c2f74643e0d0a0909090909090909093c2f74723e0d0a0d0a0909090909090909093c74723e0d0a090909090909090909093c7464206865696768743d2238223e3c2f74643e0d0a0909090909090909093c2f74723e0d0a0d0a09090909090909093c2f7461626c653e0d0a09090909090909093c2f74643e0d0a0d0a090909090909093c2f74723e0d0a0d0a090909090909093c74723e0d0a09090909090909090d0a09090909090909093c746420616c69676e3d226c656674222076616c69676e3d226d6964646c65220d0a0909090909090909097374796c653d22626f726465722d746f703a20233636362031707820736f6c69643b20626f726465722d626f74746f6d3a20233636362031707820736f6c69643b20666f6e742d73697a653a20313270783b20636f6c6f723a20233537353735373b20666f6e742d66616d696c793a20417269616c2c2048656c7665746963612c2073616e732d73657269663b223e0d0a09090909090909093c7461626c652077696474683d22353030222063656c6c70616464696e673d2230222063656c6c73706163696e673d22302220626f726465723d2230223e0d0a0d0a0d0a0909090909090909093c74723e0d0a090909090909090909093c74642077696474683d22313522206865696768743d2235223e3c2f74643e0d0a090909090909090909093c7464206865696768743d223235220d0a09090909090909090909097374796c653d22636f6c6f723a20233537353735373b20666f6e742d66616d696c793a20417269616c2c2048656c7665746963612c2073616e732d73657269663b20666f6e742d73697a653a20313370783b223e0d0a0d0a090909090909090909090d0a090909090909090909093c623e4163636f756e7420496e666f726d6174696f6e3a203c2f623e3c2f74643e0d0a0909090909090909093c2f74723e0d0a0d0a0d0a0909090909090909093c74723e0d0a090909090909090909093c74642077696474683d22313522206865696768743d2235223e3c2f74643e0d0a090909090909090909093c7464206865696768743d223230220d0a09090909090909090909097374796c653d22636f6c6f723a20233537353735373b20666f6e742d66616d696c793a20417269616c2c2048656c7665746963612c2073616e732d73657269663b20666f6e742d73697a653a20313370783b223e0d0a090909090909090909090d0a090909090909090909094669727374204e616d653a204d65726368616e742041646d696e3c2f74643e0d0a0909090909090909093c2f74723e0d0a0d0a0909090909090909093c74723e0d0a090909090909090909093c74642077696474683d22313522206865696768743d2235223e3c2f74643e0d0a090909090909090909093c7464206865696768743d223230220d0a09090909090909090909097374796c653d22636f6c6f723a20233537353735373b20666f6e742d66616d696c793a20417269616c2c2048656c7665746963612c2073616e732d73657269663b20666f6e742d73697a653a20313370783b223e4c6173740d0a090909090909090909094e616d653a204f6e653c2f74643e0d0a0909090909090909093c2f74723e0d0a0d0a0909090909090909093c74723e0d0a090909090909090909093c74642077696474683d22313522206865696768743d2235223e3c2f74643e0d0a090909090909090909093c7464206865696768743d223230220d0a09090909090909090909097374796c653d22636f6c6f723a20233537353735373b20666f6e742d66616d696c793a20417269616c2c2048656c7665746963612c2073616e732d73657269663b20666f6e742d73697a653a20313370783b223e526f6c653a0d0a090909090909090909094d65726368616e7441646d696e3c2f74643e0d0a0909090909090909093c2f74723e0d0a0d0a09090909090909093c2f7461626c653e0d0a0d0a09090909090909093c7461626c652077696474683d22353030222063656c6c70616464696e673d2230222063656c6c73706163696e673d22302220626f726465723d2230223e0d0a0d0a0d0a0909090909090909093c74723e0d0a090909090909090909093c74642077696474683d22313522206865696768743d2235223e3c2f74643e0d0a090909090909090909093c7464206865696768743d223235220d0a09090909090909090909097374796c653d22636f6c6f723a20233537353735373b20666f6e742d66616d696c793a20417269616c2c2048656c7665746963612c2073616e732d73657269663b20666f6e742d73697a653a20313370783b223e0d0a0d0a090909090909090909090d0a090909090909090909093c623e41636365737320496e666f726d6174696f6e3a3c2f623e3c2f74643e0d0a0909090909090909093c2f74723e0d0a0d0a0d0a0909090909090909093c74723e0d0a090909090909090909093c74642077696474683d22313522206865696768743d2235223e3c2f74643e0d0a090909090909090909093c7464206865696768743d223230220d0a09090909090909090909097374796c653d22636f6c6f723a20233537353735373b20666f6e742d66616d696c793a20417269616c2c2048656c7665746963612c2073616e732d73657269663b20666f6e742d73697a653a20313370783b223e0d0a090909090909090909090d0a0909090909090909090954656d706f726172792050617373776f72643a2030744837684539723c2f74643e0d0a0909090909090909093c2f74723e0d0a0d0a0909090909090909093c74723e0d0a090909090909090909093c74642077696474683d22313522206865696768743d2235223e3c2f74643e0d0a090909090909090909093c7464206865696768743d223330220d0a09090909090909090909097374796c653d22636f6c6f723a20233537353735373b20666f6e742d66616d696c793a20417269616c2c2048656c7665746963612c2073616e732d73657269663b20666f6e742d73697a653a20313370783b223e0d0a090909090909090909090d0a09090909090909090909466f6c6c6f772074686973206c696e6b20746f206163636573732074686520506f7274616c3a203c610d0a09090909090909090909097374796c653d22666f6e742d66616d696c793a20417269616c2c2048656c7665746963612c2073616e732d73657269663b20666f6e742d73697a653a20313370783b20636f6c6f723a2023353539626465220d0a0909090909090909090909687265663d2223223e687474703a2f2f6c6f63616c686f73742f7a696e6762616e672f3c2f613e3c2f74643e0d0a0909090909090909093c2f74723e0d0a0d0a09090909090909093c2f7461626c653e0d0a09090909090909093c2f74643e0d0a090909090909093c2f74723e0d0a0d0a0d0a0d0a090909090909090d0a0909090909093c2f7461626c653e0d0a0d0a0909090909093c2f74643e0d0a0909090909093c74642077696474683d223122206267636f6c6f723d2223623162316231223e3c2f74643e0d0a09090909093c2f74723e0d0a09090909093c74723e0d0a0909090909093c74642077696474683d223122206267636f6c6f723d2223623162316231223e3c2f74643e0d0a0909090909090d0a0909090909093c7464207374796c653d2270616464696e673a2030707820313070782030707820313070783b222076616c69676e3d226d6964646c65220d0a09090909090909616c69676e3d226c65667422206865696768743d223437223e0d0a0909090909093c700d0a090909090909097374796c653d22666f6e742d73697a653a20313170783b20666f6e742d66616d696c793a20417269616c2c2048656c7665746963612c2073616e732d73657269663b20636f6c6f723a20726762283130322c203130322c20313032293b20666f6e742d7765696768743a206e6f726d616c3b206d617267696e2d746f703a203570783b206d617267696e2d626f74746f6d3a203570783b20746578742d616c69676e3a206a757374696679223e446973636c61696d65723a3c62723e0d0a09090909090954686520696e666f726d6174696f6e20636f6e7461696e656420696e207468697320656c656374726f6e6963206d65737361676520616e6420616e790d0a0909090909096174746163686d656e747320746f2074686973206d6573736167652061726520696e74656e64656420666f7220746865206578636c757369766520757365206f660d0a0909090909097468652061646472657373656528732920616e64206d617920636f6e7461696e2070726f70726965746172792c20636f6e666964656e7469616c206f720d0a09090909090970726976696c6567656420696e666f726d6174696f6e2e20496620796f7520617265206e6f742074686520696e74656e64656420726563697069656e742c20796f750d0a09090909090973686f756c64206e6f742064697373656d696e6174652c2064697374726962757465206f7220636f7079207468697320652d6d61696c2e20506c656173650d0a09090909090964657374726f7920616c6c20636f70696573206f662074686973206d65737361676520616e6420616e79206174746163686d656e74732e200d0a0909090909093c2f703e0d0a0909090909093c2f74643e0d0a0909090909093c74642077696474683d223122206267636f6c6f723d2223623162316231223e3c2f74643e0d0a09090909093c2f74723e0d0a090909093c2f7461626c653e0d0a090909093c2f74643e0d0a0909093c2f74723e0d0a0d0a0d0a0d0a0d0a0d0a0d0a09093c2f7461626c653e0d0a09093c2f74643e0d0a093c2f74723e0d0a0d0a093c74723e0d0a09090d0a09093c74642077696474683d2235393622206865696768743d2237302220616c69676e3d226c656674220d0a0909097374796c653d226261636b67726f756e642d7265706561743a206e6f2d7265706561743b20666f6e742d73697a653a20313270783b20636f6c6f723a20233030303030303b20666f6e742d66616d696c793a20417269616c2c2048656c7665746963612c2073616e732d73657269663b220d0a0909096261636b67726f756e643d22687474703a2f2f6c6f63616c686f73742f7a696e6762616e672f2f7075626c69632f656d61696c496d616765732f65786163742d70656e742d636f6c6f72732d666f6f7465722e706e67223e0d0a09090d0a0d0a09093c7461626c6520626f726465723d2230222063656c6c70616464696e673d2230222063656c6c73706163696e673d2230222077696474683d22353830223e0d0a0909093c74723e0d0a090909093c74642077696474683d223135222076616c69676e3d22746f70223e3c2f74643e0d0a090909093c74642076616c69676e3d22746f70222077696474683d223635220d0a09090909097374796c653d22666f6e742d66616d696c793a20417269616c2c2048656c7665746963612c2073616e732d73657269663b20666f6e742d73697a653a20313070783b20666f6e742d7374796c653a206e6f726d616c3b20666f6e742d7765696768743a206e6f726d616c3b20636f6c6f723a20236666663b2070616464696e672d6c6566743a2033357078223e546869730d0a09090909646f63756d656e7420616e642074686520696e666f726d6174696f6e20636f6e7461696e6564207468657265696e2c206973207468652070726f70726965746172790d0a09090909616e6420636f6e666964656e7469616c20696e666f726d6174696f6e3c2f74643e0d0a0909093c2f74723e0d0a0d0a0909093c74723e0d0a090909093c74643e3c2f74643e0d0a090909093c74642077696474683d223830220d0a09090909097374796c653d22666f6e742d66616d696c793a20417269616c2c2048656c7665746963612c2073616e732d73657269663b20666f6e742d73697a653a20313070783b20666f6e742d7374796c653a206e6f726d616c3b20666f6e742d7765696768743a206e6f726d616c3b20636f6c6f723a20236666663b20746578742d616c69676e3a206a7573746966793b2070616464696e672d6c6566743a20343270783b223e6f660d0a090909094765744c696e632c20496e632e20616e642074686520646f63756d656e742c20616e642074686520696e666f726d6174696f6e0d0a09090909636f6e7461696e6564207468657265696e2c206d6179206e6f742062653c2f74643e0d0a0909093c2f74723e0d0a0d0a0909093c74723e0d0a090909093c74643e3c2f74643e0d0a090909093c74642077696474683d223830220d0a09090909097374796c653d22666f6e742d66616d696c793a20417269616c2c2048656c7665746963612c2073616e732d73657269663b20666f6e742d73697a653a20313070783b20666f6e742d7374796c653a206e6f726d616c3b20666f6e742d7765696768743a206e6f726d616c3b20636f6c6f723a20236666663b2070616464696e672d6c6566743a2034347078223e757365642c0d0a09090909636f706965642c206f7220646973636c6f73656420776974686f7574207468652065787072657373207072696f72207772697474656e20636f6e73656e74206f660d0a090909094765744c696e632c20496e632e3c2f74643e0d0a0909093c2f74723e0d0a0d0a0909093c74723e0d0a090909093c74643e3c2f74643e0d0a090909093c74642077696474683d223830220d0a09090909097374796c653d22666f6e742d66616d696c793a20417269616c2c2048656c7665746963612c2073616e732d73657269663b20666f6e742d73697a653a20313070783b20666f6e742d7374796c653a206e6f726d616c3b20666f6e742d7765696768743a20626f6c643b20636f6c6f723a20236666663b2070616464696e672d6c6566743a203133357078223e26233136390d0a0909090932303133204765744c696e632c20496e632e20416c6c207269676874732072657365727665642e3c2f74643e0d0a0909093c2f74723e0d0a09093c2f7461626c653e0d0a0d0a09093c2f74643e0d0a0d0a09090d0a0d0a093c2f74723e0d0a0d0a3c2f7461626c653e0d0a3c2f626f64793e0d0a3c2f68746d6c3e, 1, 1, '2013-06-02 15:16:00', '2013-06-02 09:46:00', NULL, 1, NULL, NULL);
INSERT INTO `apmmailqueue` (`mailqueueid`, `emailfrom`, `emailto`, `emailsubject`, `body`, `mailstatus`, `referenceid`, `createddatetime`, `updateddatetime`, `deleteddatetime`, `statusid`, `createdby`, `lastupdatedby`) VALUES
(30, 'support@getlinc.com', 'admin1@gmail.com', 'Your account has been locked', 0x3c7461626c652077696474683d223539362220626f726465723d2230222063656c6c70616464696e673d2230222063656c6c73706163696e673d2230223e0d0a093c74723e0d0a09093c74643e0d0a09093c7461626c652077696474683d22353936222063656c6c70616464696e673d2230222063656c6c73706163696e673d2230223e0d0a0909093c74723e0d0a090909093c74642076616c69676e3d22746f70220d0a09090909097374796c653d22666f6e742d73697a653a20313270783b20636f6c6f723a20233030303030303b20666f6e742d66616d696c793a2056657264616e612c2047656e6576612c2073616e732d73657269663b223e0d0a0d0a090909093c7461626c652077696474683d22353936222063656c6c70616464696e673d2230222063656c6c73706163696e673d2230223e0d0a09090909093c74723e0d0a0909090909093c746420616c69676e3d226c65667422207374796c653d22666f6e742d73697a653a20313270783b20636f6c6f723a20233030303030303b223e3c610d0a09090909090909687265663d2223223e3c696d670d0a090909090909097372633d22687474703a2f2f6c6f63616c686f73742f7a696e6762616e672f7075626c69632f7075626c69632f656d61696c496d616765732f6865616465722d4d6f62696c6546756e64732d6e65772e706e67220d0a09090909090909626f726465723d22302220616c743d22686561646572223e3c2f613e3c2f74643e0d0a09090909093c2f74723e0d0a090909093c2f7461626c653e0d0a090909093c2f74643e0d0a0909093c2f74723e0d0a0909093c74723e0d0a090909093c74643e0d0a090909093c7461626c652077696474683d223539362220626f726465723d2230222063656c6c70616464696e673d2230222063656c6c73706163696e673d2230223e0d0a09090909093c74723e0d0a0909090909093c74642077696474683d223122206267636f6c6f723d2223364542353737223e3c2f74643e0d0a0909090909093c74643e0d0a0909090909093c7461626c652077696474683d223539342220616c69676e3d2263656e74657222206267636f6c6f723d22236661666166612220626f726465723d2230220d0a0909090909090963656c6c73706163696e673d2230223e0d0a090909090909093c74723e0d0a09090909090909093c7464207374796c653d226865696768743a203570783b223e3c2f74643e0d0a090909090909093c2f74723e0d0a090909090909093c74723e0d0a09090909090909093c74640d0a0909090909090909097374796c653d22746578742d616c69676e3a2063656e7465723b206865696768743a20323570783b20666f6e742d73697a653a20313570783b20666f6e742d66616d696c793a20417269616c2c2048656c7665746963612c2073616e732d73657269663b20626f726465722d626f74746f6d2d636f6c6f723a20233636363b20626f726465722d626f74746f6d2d7374796c653a206461736865643b20626f726465722d626f74746f6d2d77696474683a203170783b220d0a090909090909090909616c69676e3d2263656e746572223e3c62207374796c653d22636f6c6f723a2023353735373537223e4c6f636b65642055736572206163636573733c2f623e3c2f74643e0d0a090909090909093c2f74723e0d0a090909090909093c74723e0d0a0d0a09090909090909093c7464206267636f6c6f723d2223464646464646222076616c69676e3d22746f70222077696474683d22353730220d0a0909090909090909097374796c653d22666f6e742d73697a653a20313370783b20666f6e742d7765696768743a206e6f726d616c3b20636f6c6f723a20233537353735373b20666f6e742d66616d696c793a20617269616c3b223e0d0a09090909090909093c7461626c652077696474683d22353130222063656c6c70616464696e673d2230222063656c6c73706163696e673d2230223e0d0a0909090909090909093c74723e0d0a090909090909090909093c7464207374796c653d226865696768743a20313070783b223e266e6273703b3c2f74643e0d0a0909090909090909093c2f74723e0d0a0909090909090909093c74723e0d0a090909090909090909093c74642077696474683d223135707822207374796c653d226865696768743a203570783b223e3c2f74643e0d0a090909090909090909093c74640d0a09090909090909090909097374796c653d22636f6c6f723a20233037356239623b20666f6e742d66616d696c793a20417269616c2c2048656c7665746963612c2073616e732d73657269663b20666f6e742d73697a653a20313470783b223e48690d0a090909090909090909090941646d696e204f6e652c3c2f74643e0d0a0909090909090909093c2f74723e0d0a0909090909090909093c74723e0d0a090909090909090909093c7464207374796c653d226865696768743a20313070783b223e266e6273703b3c2f74643e0d0a0909090909090909093c2f74723e0d0a0d0a0909090909090909093c74723e0d0a090909090909090909093c74642077696474683d223135707822207374796c653d226865696768743a203570783b223e3c2f74643e0d0a090909090909090909093c74640d0a09090909090909090909097374796c653d22636f6c6f723a20233537353735373b20666f6e742d66616d696c793a20417269616c2c2048656c7665746963612c2073616e732d73657269663b20666f6e742d73697a653a20313370783b223e596f75722061636365737320686173206265656e206c6f636b65642e3c2f74643e0d0a0909090909090909093c2f74723e0d0a0909090909090909093c74723e0d0a090909090909090909093c7464207374796c653d226865696768743a20313070783b223e266e6273703b3c2f74643e0d0a0909090909090909093c2f74723e0d0a0909090909090909093c74723e0d0a090909090909090909093c7464207374796c653d226865696768743a20313070783b223e266e6273703b3c2f74643e0d0a0909090909090909093c2f74723e0d0a09090909090909093c2f7461626c653e0d0a09090909090909093c2f74643e0d0a090909090909093c2f74723e0d0a090909090909093c74723e0d0a09090909090909093c7464207374796c653d226865696768743a20313070783b223e266e6273703b3c2f74643e0d0a090909090909093c2f74723e0d0a09090909090909200d0a090909090909093c74723e0d0a09090909090909093c7464206865696768743d223135223e3c2f74643e0d0a090909090909093c2f74723e0d0a090909090909093c74723e0d0a09090909090909093c7464206267636f6c6f723d22236631663166312220616c69676e3d226c656674222076616c69676e3d226d6964646c65220d0a0909090909090909097374796c653d22626f726465722d626f74746f6d3a203130707820736f6c696420234646464646463b20666f6e742d73697a653a20313270783b20636f6c6f723a20233537353735373b20666f6e742d66616d696c793a20417269616c2c2048656c7665746963612c2073616e732d73657269663b2070616464696e672d6c6566743a20333070783b2070616464696e672d72696768743a20333070783b223e0d0a09090909090909093c7461626c652077696474683d22353030222063656c6c70616464696e673d2230222063656c6c73706163696e673d22302220626f726465723d2230223e0d0a0909090909090909093c74723e0d0a090909090909090909093c746420616c69676e3d2263656e74657222206865696768743d223330220d0a09090909090909090909097374796c653d22636f6c6f723a20233537353735373b20666f6e742d66616d696c793a20417269616c2c2048656c7665746963612c2073616e732d73657269663b20666f6e742d73697a653a20313370783b223e0d0a0d0a09090909090909090909466f72206675727468657220617373697374616e636520656d61696c207573206174203c610d0a09090909090909090909097374796c653d22666f6e742d66616d696c793a20417269616c2c2048656c7665746963612c2073616e732d73657269663b20666f6e742d73697a653a20313270783b20636f6c6f723a2023303735623962220d0a0909090909090909090909687265663d226d61696c746f3a637573746f6d6572737570706f7274406765746c696e632e636f6d223e737570706f7274406765746c696e632e636f6d3c2f613e0d0a0d0a090909090909090909093c2f74643e0d0a0909090909090909093c2f74723e0d0a0909090909090909093c74723e0d0a090909090909090909093c746420616c69676e3d2263656e74657222206865696768743d223330220d0a09090909090909090909097374796c653d22636f6c6f723a20233537353735373b20666f6e742d66616d696c793a20417269616c2c2048656c7665746963612c2073616e732d73657269663b20666f6e742d73697a653a20313370783b223e0d0a0909090909090909090928204f5220293c2f74643e0d0a0909090909090909093c2f74723e0d0a0909090909090909093c74723e0d0a090909090909090909093c746420616c69676e3d2263656e74657222206865696768743d223330220d0a09090909090909090909097374796c653d22636f6c6f723a20233537353735373b20666f6e742d66616d696c793a20417269616c2c2048656c7665746963612c2073616e732d73657269663b20666f6e742d73697a653a20313370783b223e63616c6c0d0a090909090909090909097573206174203c61207374796c653d22636f6c6f723a2023303735623962223e2039383736353433323131203c2f613e3c2f74643e0d0a0909090909090909093c2f74723e0d0a09090909090909093c2f7461626c653e0d0a09090909090909093c2f74643e0d0a090909090909093c2f74723e0d0a0909090909093c2f7461626c653e0d0a0909090909093c2f74643e0d0a0909090909093c74642077696474683d223122206267636f6c6f723d2223364542353737223e3c2f74643e0d0a09090909093c2f74723e0d0a09090909093c74723e0d0a0909090909093c74642077696474683d223122206267636f6c6f723d2223364542353737223e3c2f74643e0d0a0909090909093c7464206267636f6c6f723d2223666166616661223e266e6273703b3c2f74643e0d0a0909090909093c74642077696474683d223122206267636f6c6f723d2223364542353737223e3c2f74643e0d0a09090909093c2f74723e0d0a09090909093c74723e0d0a0909090909093c74642077696474683d223122206267636f6c6f723d2223364542353737223e3c2f74643e0d0a0909090909093c7464206267636f6c6f723d222366616661666122207374796c653d22666f6e742d7765696768743a206e6f726d616c3b2070616464696e673a203070782031307078203070782031307078220d0a0909090909090976616c69676e3d226d6964646c652220616c69676e3d226c65667422206865696768743d223437223e0d0a0909090909093c70207374796c653d22666f6e742d73697a653a20313170783b20666f6e742d66616d696c793a20417269616c2c2048656c7665746963612c2073616e732d73657269663b20636f6c6f723a20726762283130322c203130322c20313032293b20666f6e742d7765696768743a206e6f726d616c3b223e446973636c61696d65723a3c62723e0d0a09090909090954686520696e666f726d6174696f6e20636f6e7461696e656420696e207468697320656c656374726f6e6963206d65737361676520616e6420616e790d0a0909090909096174746163686d656e747320746f2074686973206d6573736167652061726520696e74656e64656420666f7220746865206578636c757369766520757365206f660d0a0909090909097468652061646472657373656528732920616e64206d617920636f6e7461696e2070726f70726965746172792c20636f6e666964656e7469616c206f720d0a09090909090970726976696c6567656420696e666f726d6174696f6e2e20496620796f7520617265206e6f742074686520696e74656e64656420726563697069656e742c20796f750d0a09090909090973686f756c64206e6f742064697373656d696e6174652c2064697374726962757465206f7220636f7079207468697320652d6d61696c2e20506c656173650d0a0909090909096e6f746966792061743c61207374796c653d22666f6e742d66616d696c793a20417269616c2c2048656c7665746963612c2073616e732d73657269663b20666f6e742d73697a653a20313170783b20636f6c6f723a2023303735623962220d0a09090909090909687265663d226d61696c746f3a737570706f7274406765746c696e632e636f6d22207461726765743d225f626c616e6b223e0d0a090909090909737570706f7274406765746c696e632e636f6d3c2f613e20696d6d6564696174656c7920616e642064657374726f7920616c6c0d0a090909090909636f70696573206f662074686973206d65737361676520616e6420616e79206174746163686d656e74732e3c2f703e0d0a0909090909093c2f74643e0d0a0909090909093c74642077696474683d223122206267636f6c6f723d2223364542353737223e3c2f74643e0d0a09090909093c2f74723e0d0a090909093c2f7461626c653e0d0a090909093c2f74643e0d0a0909093c2f74723e0d0a09093c2f7461626c653e0d0a09093c2f74643e0d0a093c2f74723e0d0a093c74723e0d0a09093c74642077696474683d223539362220616c69676e3d226c656674220d0a0909097374796c653d226261636b67726f756e642d7265706561743a206e6f2d7265706561743b20746578742d616c69676e3a2063656e7465723b206865696768743a20343670783b20666f6e742d73697a653a20313270783b20636f6c6f723a20233030303030303b20666f6e742d66616d696c793a20417269616c2c2048656c7665746963612c2073616e732d73657269663b223e3c610d0a090909687265663d226d61696c746f3a737570706f7274406765746c696e632e636f6d223e3c696d670d0a0909097372633d22687474703a2f2f6c6f63616c686f73742f7a696e6762616e672f7075626c69632f7075626c69632f656d61696c496d616765732f666f6f7465722d4d6f62696c6566756e64732d6e65772e6a7067220d0a09090977696474683d2235393622206865696768743d2234362220626f726465723d223022207374796c653d226d617267696e2d72696768743a203270783b220d0a090909616c69676e3d226c65667422202f3e203c2f613e3c2f74643e0d0a0d0a093c2f74723e0d0a3c2f7461626c653e, 1, NULL, '2013-06-08 10:07:35', '2013-06-08 04:37:35', NULL, 1, NULL, NULL);

-- --------------------------------------------------------

--
-- Table structure for table `apmmailqueuelog`
--

CREATE TABLE IF NOT EXISTS `apmmailqueuelog` (
  `mailqueuelogid` int(11) NOT NULL AUTO_INCREMENT COMMENT 'Auto Increment ID for Mail Queue',
  `errordescription` text NOT NULL COMMENT 'Error Description for the Email y it is failed',
  `mailqueueid` int(11) NOT NULL COMMENT 'MailQueuid to know whcih email is not sent',
  `createddatetime` datetime NOT NULL COMMENT 'created date time of the record',
  `updateddatetime` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'record updated date time',
  `deleteddatetime` datetime DEFAULT NULL COMMENT 'deleted date time of the record',
  `statusid` int(11) NOT NULL COMMENT 'status of the record',
  `createdby` varchar(255) DEFAULT NULL COMMENT 'Stores MySQL User Created Details',
  `lastupdatedby` varchar(255) DEFAULT NULL COMMENT 'Stores MySQL User last updated Details',
  PRIMARY KEY (`mailqueuelogid`),
  KEY `FK_apmmailqueuelog_mailqueueid` (`mailqueueid`),
  KEY `FK_apmemailqueuelog_statusid_apmmasterrecordstate` (`statusid`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 AUTO_INCREMENT=1 ;

-- --------------------------------------------------------

--
-- Table structure for table `apmmasteractions`
--

CREATE TABLE IF NOT EXISTS `apmmasteractions` (
  `actionid` int(11) NOT NULL AUTO_INCREMENT COMMENT 'auto key column for actions in the controllers',
  `actionname` varchar(255) NOT NULL COMMENT 'action name in the controller for the apm portal',
  `controllerid` int(11) NOT NULL COMMENT 'controller to which the action belongs to',
  `createddatetime` datetime NOT NULL COMMENT 'created date time for this record',
  `updateddatetime` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'record updated date time',
  `deleteddatetime` datetime DEFAULT NULL COMMENT 'deleted date for this record',
  `statusid` int(11) NOT NULL COMMENT 'status of this record and foreign key for recordsstate table',
  `createdby` varchar(255) DEFAULT NULL COMMENT 'Stores MySQL User Created Details',
  `lastupdatedby` varchar(255) DEFAULT NULL COMMENT 'Stores MySQL User last updated Details',
  PRIMARY KEY (`actionid`),
  UNIQUE KEY `UQ_controllerid_actionname` (`controllerid`,`actionname`),
  KEY `FK_apmmasteractions_statusid_apmmasterrecordsstate` (`statusid`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 COMMENT='all actions of different controllers developed for the apm p' AUTO_INCREMENT=92 ;

--
-- Dumping data for table `apmmasteractions`
--

INSERT INTO `apmmasteractions` (`actionid`, `actionname`, `controllerid`, `createddatetime`, `updateddatetime`, `deleteddatetime`, `statusid`, `createdby`, `lastupdatedby`) VALUES
(1, 'index', 1, '2012-03-30 17:31:22', '2013-03-30 04:36:56', NULL, 1, NULL, NULL),
(2, 'firstlogin', 1, '2012-03-30 17:31:26', '2013-03-30 04:36:56', NULL, 1, NULL, NULL),
(3, 'index', 2, '2012-04-19 17:43:55', '2013-03-30 04:36:56', NULL, 1, NULL, NULL),
(4, 'login', 2, '2012-04-19 17:44:03', '2013-03-30 04:36:56', NULL, 1, NULL, NULL),
(5, 'success', 2, '2012-04-19 17:44:15', '2013-03-30 04:36:56', NULL, 1, NULL, NULL),
(6, 'logout', 2, '2012-04-19 17:44:22', '2013-03-30 04:36:56', NULL, 1, NULL, NULL),
(7, 'checkusersession', 2, '2012-04-19 17:44:32', '2013-03-30 04:36:56', NULL, 1, NULL, NULL),
(8, 'index', 3, '2012-04-19 17:47:02', '2013-03-30 04:36:56', NULL, 1, NULL, NULL),
(9, 'register', 3, '2012-04-19 17:47:11', '2013-03-30 04:36:56', NULL, 1, NULL, NULL),
(10, 'createuser', 3, '2012-04-19 17:47:21', '2013-03-30 04:36:56', NULL, 1, NULL, NULL),
(11, 'list', 3, '2012-04-19 17:47:32', '2013-03-30 04:36:56', NULL, 1, NULL, NULL),
(12, 'useredit', 3, '2012-04-19 17:47:43', '2013-03-30 04:36:56', NULL, 1, NULL, NULL),
(13, 'newuser', 3, '2012-04-19 17:47:54', '2013-03-30 04:36:56', NULL, 1, NULL, NULL),
(15, 'savefirst', 1, '2012-04-19 17:51:23', '2013-03-30 04:36:56', NULL, 1, NULL, NULL),
(16, 'firstsecurity', 1, '2012-04-19 17:51:34', '2013-03-30 04:36:56', NULL, 1, NULL, NULL),
(17, 'asksecurity', 1, '2012-05-10 11:54:18', '2013-03-30 04:36:56', NULL, 2, NULL, NULL),
(18, 'checksecurity', 1, '2012-05-10 11:54:18', '2013-03-30 04:36:56', NULL, 1, NULL, NULL),
(19, 'resetpasswordrequired', 1, '2012-05-10 11:54:18', '2013-03-30 04:36:56', NULL, 1, NULL, NULL),
(20, 'success', 1, '2012-05-10 11:54:18', '2013-03-30 04:36:56', NULL, 1, NULL, NULL),
(21, 'savefirstsecurity', 1, '2012-05-10 11:54:18', '2013-03-30 04:36:56', NULL, 1, NULL, NULL),
(24, 'changepassword', 1, '2012-05-11 12:06:39', '2013-03-30 04:36:56', NULL, 1, NULL, NULL),
(25, 'savechangepassword', 1, '2012-05-11 12:06:39', '2013-03-30 04:36:56', NULL, 1, NULL, NULL),
(26, 'changesecurity', 1, '2012-05-14 06:33:26', '2013-03-30 04:36:56', NULL, 1, NULL, NULL),
(27, 'savechangesecurity', 1, '2012-05-14 06:33:26', '2013-03-30 04:36:56', NULL, 1, NULL, NULL),
(29, 'forgotpassword', 2, '2012-05-15 11:16:03', '2013-03-30 04:36:56', NULL, 1, NULL, NULL),
(30, 'checkforgotpasswordlogin', 2, '2012-05-15 11:16:03', '2013-03-30 04:36:56', NULL, 1, NULL, NULL),
(31, 'forgotquestion', 2, '2012-05-15 11:16:03', '2013-03-30 04:36:56', NULL, 1, NULL, NULL),
(32, 'checkforgotquestion', 2, '2012-05-15 11:16:03', '2013-03-30 04:36:56', NULL, 1, NULL, NULL),
(33, 'forgotsuccess', 2, '2012-05-15 11:16:03', '2013-03-30 04:36:56', NULL, 1, NULL, NULL),
(36, 'generateforgotpassword', 2, '2012-05-15 11:54:10', '2013-03-30 04:36:56', NULL, 1, NULL, NULL),
(37, 'lockuser', 3, '2012-06-01 07:18:59', '2013-03-30 04:36:56', NULL, 1, NULL, NULL),
(38, 'unlockuser', 3, '2012-06-01 07:18:59', '2013-03-30 04:36:56', NULL, 1, NULL, NULL),
(39, 'deleteuser', 3, '2012-06-01 07:18:59', '2013-03-30 04:36:56', NULL, 1, NULL, NULL),
(41, 'updateuserdetails', 3, '2012-06-01 20:06:58', '2013-03-30 04:36:56', NULL, 1, NULL, NULL),
(42, 'personalinfo', 1, '2012-06-06 18:19:13', '2013-03-30 04:36:56', NULL, 1, NULL, NULL),
(43, 'personalinfoupdate', 1, '2012-06-06 18:19:13', '2013-03-30 04:36:56', NULL, 1, NULL, NULL),
(45, 'forgotfailure', 2, '2012-06-07 18:50:14', '2013-03-30 04:36:56', NULL, 1, NULL, NULL),
(46, 'setLayout', 2, '2012-06-07 18:51:43', '2013-03-30 04:36:56', NULL, 1, NULL, NULL),
(47, 'setpassword', 1, '2012-06-07 20:46:23', '2013-03-30 04:36:56', NULL, 1, NULL, NULL),
(48, 'saveset', 1, '2012-06-07 20:46:23', '2013-03-30 04:36:56', NULL, 1, NULL, NULL),
(50, 'resetsecurity', 3, '2012-06-07 20:53:36', '2013-03-30 04:36:56', NULL, 1, NULL, NULL),
(51, 'resetpassword', 3, '2012-06-07 20:53:36', '2013-03-30 04:36:56', NULL, 1, NULL, NULL),
(53, 'error', 4, '2012-06-07 22:09:14', '2013-03-30 04:36:56', NULL, 1, NULL, NULL),
(54, 'getLog', 4, '2012-06-07 22:09:14', '2013-03-30 04:36:56', NULL, 1, NULL, NULL),
(56, 'accessdenied', 4, '2012-06-08 01:50:33', '2013-03-30 04:36:56', NULL, 1, NULL, NULL),
(64, 'checkusernameexistance', 2, '2012-06-12 15:41:09', '2013-03-30 04:36:56', NULL, 1, NULL, NULL),
(65, 'checkemailvalidate', 2, '2012-06-12 17:15:48', '2013-03-30 04:36:56', NULL, 1, NULL, NULL),
(91, 'index', 5, '2013-04-04 00:00:00', '2013-04-04 10:18:40', '2013-04-04 00:00:00', 1, NULL, NULL);

-- --------------------------------------------------------

--
-- Table structure for table `apmmastercontrollers`
--

CREATE TABLE IF NOT EXISTS `apmmastercontrollers` (
  `controllerid` int(11) NOT NULL AUTO_INCREMENT COMMENT 'auto key column for controllers in the modules',
  `controllername` varchar(255) NOT NULL COMMENT 'controller name in the module for the apm portal',
  `moduleid` int(11) NOT NULL COMMENT 'module to which the controller belongs to',
  `createddatetime` datetime NOT NULL COMMENT 'created date time for this record',
  `updateddatetime` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'record updated date time',
  `deleteddatetime` datetime DEFAULT NULL COMMENT 'deleted date for this record',
  `statusid` int(11) NOT NULL COMMENT 'status of this record and foreign key for recordsstate table',
  `createdby` varchar(255) DEFAULT NULL COMMENT 'Stores MySQL User Created Details',
  `lastupdatedby` varchar(255) DEFAULT NULL COMMENT 'Stores MySQL User last updated Details',
  PRIMARY KEY (`controllerid`),
  UNIQUE KEY `UQ_moduleid_controllername` (`moduleid`,`controllername`),
  KEY `FK_apmmastercontrollers_statusid_apmmasterrecordsstate` (`statusid`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 COMMENT='all controllers of different modules developed for the apm p' AUTO_INCREMENT=6 ;

--
-- Dumping data for table `apmmastercontrollers`
--

INSERT INTO `apmmastercontrollers` (`controllerid`, `controllername`, `moduleid`, `createddatetime`, `updateddatetime`, `deleteddatetime`, `statusid`, `createdby`, `lastupdatedby`) VALUES
(1, 'index', 1, '2012-03-30 11:54:52', '2013-03-30 04:30:56', NULL, 1, NULL, NULL),
(2, 'index', 4, '2012-04-19 17:40:34', '2013-04-04 10:11:52', NULL, 1, NULL, NULL),
(3, 'user', 1, '2012-04-19 17:45:35', '2013-03-30 04:30:56', NULL, 1, NULL, NULL),
(4, 'error', 7, '2012-06-07 22:07:06', '2013-04-04 10:10:05', NULL, 1, NULL, NULL),
(5, 'index', 7, '2013-04-04 00:00:00', '2013-04-04 10:17:49', NULL, 1, NULL, NULL);

-- --------------------------------------------------------

--
-- Table structure for table `apmmastermailstatus`
--

CREATE TABLE IF NOT EXISTS `apmmastermailstatus` (
  `mailstatusid` int(11) NOT NULL AUTO_INCREMENT COMMENT 'auto unique key for differnt states of the records',
  `mailstate` varchar(255) NOT NULL COMMENT 'state mail types of the record',
  `createddatetime` datetime NOT NULL COMMENT 'created date time for the record',
  `updateddatetime` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'record updated date time',
  `deleteddatetime` varchar(255) DEFAULT NULL COMMENT 'Stores record deleted datetime Details',
  `createdby` varchar(255) DEFAULT NULL COMMENT 'Stores MySQL User Created Details',
  `lastupdatedby` varchar(255) DEFAULT NULL COMMENT 'Stores MySQL User last updated Details',
  PRIMARY KEY (`mailstatusid`) USING BTREE,
  UNIQUE KEY `UQ_mailstate` (`mailstate`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 COMMENT='all possible states of the mails stored here' AUTO_INCREMENT=6 ;

--
-- Dumping data for table `apmmastermailstatus`
--

INSERT INTO `apmmastermailstatus` (`mailstatusid`, `mailstate`, `createddatetime`, `updateddatetime`, `deleteddatetime`, `createdby`, `lastupdatedby`) VALUES
(1, 'emailnotsent', '2012-08-09 09:03:48', '2013-04-05 09:30:38', NULL, NULL, NULL),
(2, 'emailpicked', '2012-08-09 09:10:35', '2013-04-05 09:30:38', NULL, NULL, NULL),
(3, 'emailsending', '2012-08-09 09:10:58', '2013-04-05 09:30:38', NULL, NULL, NULL),
(4, 'emailsent', '2012-08-09 17:08:37', '2013-04-05 09:30:38', NULL, NULL, NULL),
(5, 'errored', '2012-08-09 17:08:37', '2013-04-05 09:30:38', NULL, NULL, NULL);

-- --------------------------------------------------------

--
-- Table structure for table `apmmastermodules`
--

CREATE TABLE IF NOT EXISTS `apmmastermodules` (
  `moduleid` int(11) NOT NULL AUTO_INCREMENT COMMENT 'auto key column for modules',
  `modulename` varchar(255) NOT NULL COMMENT 'module name in the apm portal',
  `createddatetime` datetime NOT NULL COMMENT 'created date time for this record',
  `updateddatetime` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'record updated date time',
  `deleteddatetime` datetime DEFAULT NULL COMMENT 'deleted date for this record',
  `statusid` int(11) NOT NULL COMMENT 'status of this record and foreign key for recordsstate table',
  `createdby` varchar(255) DEFAULT NULL COMMENT 'Stores MySQL User Created Details',
  `lastupdatedby` varchar(255) DEFAULT NULL COMMENT 'Stores MySQL User last updated Details',
  PRIMARY KEY (`moduleid`),
  UNIQUE KEY `UQ_modulename` (`modulename`),
  KEY `FK_apmmastermodules_statusid_apmmasterrecordsstate` (`statusid`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 COMMENT='all modules developed for the apm portal are saved here' AUTO_INCREMENT=8 ;

--
-- Dumping data for table `apmmastermodules`
--

INSERT INTO `apmmastermodules` (`moduleid`, `modulename`, `createddatetime`, `updateddatetime`, `deleteddatetime`, `statusid`, `createdby`, `lastupdatedby`) VALUES
(1, 'usermanagement', '2012-03-26 17:53:02', '2013-03-30 03:56:36', NULL, 1, NULL, NULL),
(4, 'admin', '2012-04-13 12:25:47', '2013-04-04 10:08:36', NULL, 1, NULL, NULL),
(7, 'default', '2013-04-04 00:00:00', '2013-04-04 10:08:42', NULL, 1, NULL, NULL);

-- --------------------------------------------------------

--
-- Table structure for table `apmmasterrecordsstate`
--

CREATE TABLE IF NOT EXISTS `apmmasterrecordsstate` (
  `statusid` int(11) NOT NULL AUTO_INCREMENT COMMENT 'auto unique key for differnt states of the records',
  `recordstate` varchar(255) NOT NULL COMMENT 'state name of the record',
  `createddatetime` datetime NOT NULL COMMENT 'created date time for the record',
  `updateddatetime` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'record updated date time',
  `deleteddatetime` varchar(255) DEFAULT NULL COMMENT 'Stores record deleted datetime Details',
  `createdby` varchar(255) DEFAULT NULL COMMENT 'Stores MySQL User Created Details',
  `lastupdatedby` varchar(255) DEFAULT NULL COMMENT 'Stores MySQL User last updated Details',
  PRIMARY KEY (`statusid`) USING BTREE,
  UNIQUE KEY `UQ_recordstate` (`recordstate`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 COMMENT='all possible states of the records are stored here' AUTO_INCREMENT=7 ;

--
-- Dumping data for table `apmmasterrecordsstate`
--

INSERT INTO `apmmasterrecordsstate` (`statusid`, `recordstate`, `createddatetime`, `updateddatetime`, `deleteddatetime`, `createdby`, `lastupdatedby`) VALUES
(1, 'Active', '2012-03-26 14:28:02', '2013-04-01 16:31:40', NULL, NULL, NULL),
(2, 'Inactive', '2012-03-26 14:28:19', '2013-04-01 16:31:40', NULL, NULL, NULL),
(3, 'Deleted', '2012-03-26 14:28:39', '2013-04-01 16:31:40', NULL, NULL, NULL),
(4, 'Pending', '2012-03-28 15:29:00', '2013-04-01 16:31:40', NULL, NULL, NULL),
(5, 'Declined', '2012-03-28 15:29:46', '2013-04-01 16:31:40', NULL, NULL, NULL),
(6, 'Locked', '2012-04-02 17:47:09', '2013-04-01 16:31:40', NULL, NULL, NULL);

-- --------------------------------------------------------

--
-- Table structure for table `apmmasterroleprivileges`
--

CREATE TABLE IF NOT EXISTS `apmmasterroleprivileges` (
  `userprivilegeid` int(11) NOT NULL AUTO_INCREMENT COMMENT 'auto key column for userprivileges',
  `roleid` int(11) NOT NULL COMMENT 'role to which set of privileges are added',
  `actionid` int(11) NOT NULL COMMENT 'action id for the role',
  `createddatetime` datetime NOT NULL COMMENT 'created date time for this record',
  `updateddatetime` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'record updated date time',
  `deleteddatetime` datetime DEFAULT NULL COMMENT 'deleted date for this record',
  `statusid` int(11) NOT NULL COMMENT 'status of this record and foreign key for recordsstate table',
  `createdby` varchar(255) DEFAULT NULL COMMENT 'Stores MySQL User Created Details',
  `lastupdatedby` varchar(255) DEFAULT NULL COMMENT 'Stores MySQL User last updated Details',
  PRIMARY KEY (`userprivilegeid`),
  UNIQUE KEY `UQ_roleid_actionid` (`roleid`,`actionid`),
  KEY `FK_apmmasterroleprivileges_actionid_apmmasteractions` (`actionid`),
  KEY `FK_apmmasterroleprivileges_statusid_apmmasterrecordsstate` (`statusid`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 COMMENT='all role privileges for the corresponding roles are saved he' AUTO_INCREMENT=359 ;

--
-- Dumping data for table `apmmasterroleprivileges`
--

INSERT INTO `apmmasterroleprivileges` (`userprivilegeid`, `roleid`, `actionid`, `createddatetime`, `updateddatetime`, `deleteddatetime`, `statusid`, `createdby`, `lastupdatedby`) VALUES
(284, 5, 1, '0000-00-00 00:00:00', '2013-03-29 19:46:33', NULL, 1, NULL, NULL),
(285, 5, 2, '0000-00-00 00:00:00', '2013-03-29 19:46:33', NULL, 1, NULL, NULL),
(286, 5, 3, '0000-00-00 00:00:00', '2013-03-29 19:46:33', NULL, 1, NULL, NULL),
(287, 5, 4, '0000-00-00 00:00:00', '2013-03-29 19:46:33', NULL, 1, NULL, NULL),
(288, 5, 5, '0000-00-00 00:00:00', '2013-03-29 19:46:33', NULL, 1, NULL, NULL),
(289, 5, 6, '0000-00-00 00:00:00', '2013-03-29 19:46:33', NULL, 1, NULL, NULL),
(290, 5, 7, '0000-00-00 00:00:00', '2013-03-29 19:46:33', NULL, 1, NULL, NULL),
(291, 5, 8, '0000-00-00 00:00:00', '2013-03-29 19:46:33', NULL, 1, NULL, NULL),
(292, 5, 9, '0000-00-00 00:00:00', '2013-03-29 19:46:33', NULL, 1, NULL, NULL),
(293, 5, 10, '0000-00-00 00:00:00', '2013-03-29 19:46:33', NULL, 1, NULL, NULL),
(294, 5, 11, '0000-00-00 00:00:00', '2013-03-29 19:46:33', NULL, 1, NULL, NULL),
(295, 5, 12, '0000-00-00 00:00:00', '2013-03-29 19:46:33', NULL, 1, NULL, NULL),
(296, 5, 13, '0000-00-00 00:00:00', '2013-03-29 19:46:33', NULL, 1, NULL, NULL),
(297, 5, 15, '0000-00-00 00:00:00', '2013-03-29 19:46:33', NULL, 1, NULL, NULL),
(298, 5, 16, '0000-00-00 00:00:00', '2013-03-29 19:46:33', NULL, 1, NULL, NULL),
(299, 5, 18, '0000-00-00 00:00:00', '2013-03-29 19:46:33', NULL, 1, NULL, NULL),
(300, 5, 19, '0000-00-00 00:00:00', '2013-03-29 19:46:33', NULL, 1, NULL, NULL),
(301, 5, 20, '0000-00-00 00:00:00', '2013-03-29 19:46:33', NULL, 1, NULL, NULL),
(302, 5, 21, '0000-00-00 00:00:00', '2013-03-29 19:46:33', NULL, 1, NULL, NULL),
(303, 5, 24, '0000-00-00 00:00:00', '2013-03-29 19:46:33', NULL, 1, NULL, NULL),
(304, 5, 25, '0000-00-00 00:00:00', '2013-03-29 19:46:33', NULL, 1, NULL, NULL),
(305, 5, 26, '0000-00-00 00:00:00', '2013-03-29 19:46:33', NULL, 1, NULL, NULL),
(306, 5, 27, '0000-00-00 00:00:00', '2013-03-29 19:46:33', NULL, 1, NULL, NULL),
(307, 5, 29, '0000-00-00 00:00:00', '2013-03-29 19:46:33', NULL, 1, NULL, NULL),
(308, 5, 30, '0000-00-00 00:00:00', '2013-03-29 19:46:33', NULL, 1, NULL, NULL),
(309, 5, 31, '0000-00-00 00:00:00', '2013-03-29 19:46:33', NULL, 1, NULL, NULL),
(310, 5, 32, '0000-00-00 00:00:00', '2013-03-29 19:46:33', NULL, 1, NULL, NULL),
(311, 5, 33, '0000-00-00 00:00:00', '2013-03-29 19:46:33', NULL, 1, NULL, NULL),
(312, 5, 36, '0000-00-00 00:00:00', '2013-03-29 19:46:33', NULL, 1, NULL, NULL),
(313, 5, 37, '0000-00-00 00:00:00', '2013-03-29 19:46:33', NULL, 1, NULL, NULL),
(314, 5, 38, '0000-00-00 00:00:00', '2013-03-29 19:46:33', NULL, 1, NULL, NULL),
(315, 5, 39, '0000-00-00 00:00:00', '2013-03-29 19:46:33', NULL, 1, NULL, NULL),
(316, 5, 41, '0000-00-00 00:00:00', '2013-03-29 19:46:33', NULL, 1, NULL, NULL),
(317, 5, 42, '0000-00-00 00:00:00', '2013-03-29 19:46:33', NULL, 1, NULL, NULL),
(318, 5, 43, '0000-00-00 00:00:00', '2013-03-29 19:46:33', NULL, 1, NULL, NULL),
(319, 5, 45, '0000-00-00 00:00:00', '2013-03-29 19:46:33', NULL, 1, NULL, NULL),
(320, 5, 46, '0000-00-00 00:00:00', '2013-03-29 19:46:33', NULL, 1, NULL, NULL),
(321, 5, 47, '0000-00-00 00:00:00', '2013-03-29 19:46:33', NULL, 1, NULL, NULL),
(322, 5, 48, '0000-00-00 00:00:00', '2013-03-29 19:46:33', NULL, 1, NULL, NULL),
(323, 5, 50, '0000-00-00 00:00:00', '2013-03-29 19:46:33', NULL, 1, NULL, NULL),
(324, 5, 51, '0000-00-00 00:00:00', '2013-03-29 19:46:33', NULL, 1, NULL, NULL),
(325, 5, 53, '0000-00-00 00:00:00', '2013-03-29 19:46:33', NULL, 1, NULL, NULL),
(326, 5, 54, '0000-00-00 00:00:00', '2013-03-29 19:46:33', NULL, 1, NULL, NULL),
(327, 5, 56, '0000-00-00 00:00:00', '2013-03-29 19:46:33', NULL, 1, NULL, NULL),
(333, 5, 64, '0000-00-00 00:00:00', '2013-03-29 19:46:33', NULL, 1, NULL, NULL),
(334, 5, 65, '0000-00-00 00:00:00', '2013-03-29 19:46:33', NULL, 1, NULL, NULL),
(353, 5, 17, '0000-00-00 00:00:00', '2013-03-29 19:46:33', NULL, 1, NULL, NULL),
(358, 5, 91, '2013-04-04 00:00:00', '2013-04-04 10:20:22', '2013-04-04 00:00:00', 1, NULL, NULL);

-- --------------------------------------------------------

--
-- Table structure for table `apmmasterroles`
--

CREATE TABLE IF NOT EXISTS `apmmasterroles` (
  `roleid` int(11) NOT NULL AUTO_INCREMENT COMMENT 'auto key column for roles',
  `rolename` varchar(255) NOT NULL COMMENT 'role name',
  `priority` int(11) NOT NULL COMMENT 'Role priority',
  `createddatetime` datetime NOT NULL COMMENT 'created date time for this record',
  `updateddatetime` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'record updated date time',
  `deleteddatetime` datetime DEFAULT NULL COMMENT 'deleted date for this record',
  `statusid` int(11) NOT NULL COMMENT 'status of this record and foreign key for recordsstate table',
  `createdby` varchar(255) DEFAULT NULL COMMENT 'Stores MySQL User Created Details',
  `lastupdatedby` varchar(255) DEFAULT NULL COMMENT 'Stores MySQL User last updated Details',
  PRIMARY KEY (`roleid`),
  UNIQUE KEY `UQ_usertypeid_rolename_priority` (`rolename`,`priority`) USING BTREE,
  KEY `FK_apmmasterroles_statusid_apmmasterrecordsstate` (`statusid`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 COMMENT='all possible roles for the apm portal' AUTO_INCREMENT=11 ;

--
-- Dumping data for table `apmmasterroles`
--

INSERT INTO `apmmasterroles` (`roleid`, `rolename`, `priority`, `createddatetime`, `updateddatetime`, `deleteddatetime`, `statusid`, `createdby`, `lastupdatedby`) VALUES
(5, 'Superadmin', 1, '2012-04-09 17:45:44', '2013-04-05 09:31:17', NULL, 1, NULL, NULL),
(8, 'Admin', 2, '2012-04-11 12:26:01', '2013-04-05 09:31:17', NULL, 1, NULL, NULL),
(9, 'MerchantAdmin', 3, '2012-04-11 12:26:01', '2013-04-12 17:17:07', NULL, 1, NULL, NULL),
(10, 'User', 4, '2012-04-11 12:26:01', '2013-05-27 11:31:30', NULL, 1, NULL, NULL);

-- --------------------------------------------------------

--
-- Table structure for table `apmmasteruseractions`
--

CREATE TABLE IF NOT EXISTS `apmmasteruseractions` (
  `useractionid` int(11) NOT NULL AUTO_INCREMENT COMMENT 'Auto incremented value for user actions',
  `useraction` varchar(255) NOT NULL COMMENT 'User action',
  `useractiondesc` varchar(255) NOT NULL COMMENT 'Descrition about User action',
  `createddatetime` datetime NOT NULL COMMENT 'created date time for this record',
  `updateddatetime` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'record updated date time',
  `deleteddatetime` datetime DEFAULT NULL COMMENT 'deleted date for this record',
  `statusid` int(11) NOT NULL COMMENT 'status of this record and foreign key for recordsstate table',
  `createdby` varchar(255) DEFAULT NULL COMMENT 'Stores MySQL User Created Details',
  `lastupdatedby` varchar(255) DEFAULT NULL COMMENT 'Stores MySQL User last updated Details',
  PRIMARY KEY (`useractionid`),
  KEY `FK_apmuseractions_statusid_apmmasterrecordsstate` (`statusid`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 COMMENT='User actions are saved here' AUTO_INCREMENT=73 ;

--
-- Dumping data for table `apmmasteruseractions`
--

INSERT INTO `apmmasteruseractions` (`useractionid`, `useraction`, `useractiondesc`, `createddatetime`, `updateddatetime`, `deleteddatetime`, `statusid`, `createdby`, `lastupdatedby`) VALUES
(1, 'Login', 'User login for portal', '2012-05-10 06:36:32', '2013-04-05 09:31:51', NULL, 1, NULL, NULL),
(2, 'First Login', 'User login for the first time in portal', '2012-05-10 06:36:32', '2013-04-05 09:31:51', NULL, 1, NULL, NULL),
(3, 'Register security questions', 'User registering security questions for portal', '2012-05-10 06:36:32', '2013-04-05 09:31:51', NULL, 1, NULL, NULL),
(4, 'Answer security questions', 'User answering security questions to login to portal', '2012-05-10 06:36:32', '2013-04-05 09:31:51', NULL, 1, NULL, NULL),
(5, 'Add User', 'Adding a new user for portal', '2012-05-10 06:36:32', '2013-04-05 09:31:51', NULL, 1, NULL, NULL),
(6, 'Change Password', 'Changing user password for user in portal', '2012-05-10 06:36:32', '2013-04-05 09:31:51', NULL, 1, NULL, NULL),
(7, 'Change security questions', 'Changing security questions for user in portal', '2012-05-10 06:36:32', '2013-04-05 09:31:51', NULL, 1, NULL, NULL),
(8, 'List registered users', 'Listing registered users in portal', '2012-05-10 06:36:32', '2013-04-05 09:31:51', NULL, 1, NULL, NULL),
(10, 'temp', 'temp', '2012-05-10 06:48:51', '2013-04-05 09:31:51', NULL, 1, NULL, NULL),
(11, 'Update security questions', 'Updating security questions for a user', '2012-05-11 07:03:38', '2013-04-05 09:31:51', NULL, 1, NULL, NULL),
(13, 'Forgot Password', 'Forgot password for a user', '2012-05-11 10:23:19', '2013-04-05 09:31:51', NULL, 1, NULL, NULL),
(14, 'Check Idle action', 'Checking idle action time out', '2012-05-17 05:33:29', '2013-04-05 09:31:51', NULL, 1, NULL, NULL),
(15, 'Edit user', 'Editing user details', '2012-05-31 10:29:49', '2013-04-05 09:31:51', NULL, 1, NULL, NULL),
(16, 'Lock user', 'Locking user', '2012-05-31 10:29:49', '2013-04-05 09:31:51', NULL, 1, NULL, NULL),
(17, 'Unlock user', 'Unlocking a user', '2012-05-31 10:29:49', '2013-04-05 09:31:51', NULL, 1, NULL, NULL),
(18, 'Reset Password', 'Resetting password for a user', '2012-05-31 10:29:49', '2013-04-05 09:31:51', NULL, 1, NULL, NULL),
(19, 'Reset Security', 'Resetting security question', '2012-05-31 10:29:49', '2013-04-05 09:31:51', NULL, 1, NULL, NULL),
(22, 'Delete user', 'Deleting user', '2012-05-31 14:47:37', '2013-04-05 09:31:51', NULL, 1, NULL, NULL),
(23, 'User edit by admin', 'User details edited by admin', '2012-06-01 21:04:23', '2013-04-05 09:31:51', NULL, 1, NULL, NULL),
(24, 'update personal info', 'Updating personal information', '2012-06-06 18:20:39', '2013-04-05 09:31:51', NULL, 1, NULL, NULL),
(25, 'Add Category', 'Adding a new product category', '0000-00-00 00:00:00', '2013-04-16 11:38:42', NULL, 1, NULL, NULL),
(26, 'Edit category', 'Editing category details', '0000-00-00 00:00:00', '2013-04-16 12:11:38', NULL, 1, NULL, NULL),
(27, 'Lock category', 'Locking category', '0000-00-00 00:00:00', '2013-04-16 12:11:38', NULL, 1, NULL, NULL),
(28, 'Unlock category', 'Unlocking a category', '0000-00-00 00:00:00', '2013-04-16 12:11:38', NULL, 1, NULL, NULL),
(29, 'Delete category', 'Deleting category', '0000-00-00 00:00:00', '2013-04-16 12:11:53', NULL, 1, NULL, NULL),
(31, 'Add Category Image', 'Adding a image to category', '0000-00-00 00:00:00', '2013-04-16 17:28:31', NULL, 1, NULL, NULL),
(32, 'Lock merchant', 'Locking merchant', '0000-00-00 00:00:00', '2013-04-20 09:32:06', NULL, 1, NULL, NULL),
(37, 'Unlock merchant', 'Unlocking a merchant', '0000-00-00 00:00:00', '2013-04-20 09:55:25', NULL, 1, NULL, NULL),
(38, 'Delete merchant', 'Deleting merchant', '0000-00-00 00:00:00', '2013-04-20 09:55:25', NULL, 1, NULL, NULL),
(39, 'Add Merchant', 'Adding a new merchant', '0000-00-00 00:00:00', '2013-04-20 10:33:43', NULL, 1, NULL, NULL),
(40, 'Edit Merchant', 'Editing merchant details', '0000-00-00 00:00:00', '2013-04-20 14:52:47', NULL, 1, NULL, NULL),
(42, 'Add Attribute', 'Adding a new attribute', '0000-00-00 00:00:00', '2013-04-20 17:45:30', NULL, 1, NULL, NULL),
(43, 'Lock attribute', 'Locking attribute', '0000-00-00 00:00:00', '2013-04-20 18:58:53', NULL, 1, NULL, NULL),
(44, 'Unlock attribute', 'Unlocking a attribute', '0000-00-00 00:00:00', '2013-04-20 18:58:53', NULL, 1, NULL, NULL),
(45, 'Delete attribute', 'Deleting attribute', '0000-00-00 00:00:00', '2013-04-20 18:58:53', NULL, 1, NULL, NULL),
(46, 'Edit attribute', 'Editing attribute details', '0000-00-00 00:00:00', '2013-04-21 16:14:34', NULL, 1, NULL, NULL),
(47, 'Lock attributesets', 'Locking attributesets', '0000-00-00 00:00:00', '2013-04-21 17:22:30', NULL, 1, NULL, NULL),
(48, 'Unlock attributesets', 'Unlocking a attributesets', '0000-00-00 00:00:00', '2013-04-21 17:22:30', NULL, 1, NULL, NULL),
(49, 'Delete attributesets', 'Deleting attributesets', '0000-00-00 00:00:00', '2013-04-21 17:22:30', NULL, 1, NULL, NULL),
(50, 'Add Attributesets', 'Adding a new attributesets', '0000-00-00 00:00:00', '2013-04-22 15:15:24', NULL, 1, NULL, NULL),
(51, 'Edit attributesets', 'Editing attributesets details', '0000-00-00 00:00:00', '2013-04-22 17:06:38', NULL, 1, NULL, NULL),
(52, 'Delete Category Image', 'Deleting category image', '0000-00-00 00:00:00', '2013-04-23 09:54:55', NULL, 1, NULL, NULL),
(53, 'Add Merchant Image', 'Adding a image to merchant', '0000-00-00 00:00:00', '2013-04-25 05:58:22', NULL, 1, NULL, NULL),
(54, 'Delete Merchant Image', 'Deleting merchant image', '0000-00-00 00:00:00', '2013-04-25 06:22:12', NULL, 1, NULL, NULL),
(55, 'Add Attribute Group', 'Adding a new attributegroups', '0000-00-00 00:00:00', '2013-04-28 05:44:55', NULL, 1, NULL, NULL),
(56, 'Edit attribute group', 'Editing attributegroups details', '0000-00-00 00:00:00', '2013-04-28 06:02:34', NULL, 1, NULL, NULL),
(57, 'Lock attribute group', 'Locking attributegroups', '0000-00-00 00:00:00', '2013-04-28 07:28:52', NULL, 1, NULL, NULL),
(58, 'Unlock attribute group', 'Unlocking a attributegroups', '0000-00-00 00:00:00', '2013-04-28 07:28:52', NULL, 1, NULL, NULL),
(59, 'Delete attribute group', 'Deleting attributegroups', '0000-00-00 00:00:00', '2013-04-28 07:28:52', NULL, 1, NULL, NULL),
(60, 'Add Product', 'Adding a new product', '0000-00-00 00:00:00', '2013-05-01 10:38:36', NULL, 1, NULL, NULL),
(62, 'Add Product Images', 'Adding a new product image', '0000-00-00 00:00:00', '2013-05-18 18:37:07', NULL, 1, NULL, NULL),
(63, 'Delete product image', 'Deleting product image', '0000-00-00 00:00:00', '2013-05-19 20:33:42', NULL, 1, NULL, NULL),
(64, 'Unlock product image', 'Unlocking a product image', '0000-00-00 00:00:00', '2013-05-19 20:34:52', NULL, 1, NULL, NULL),
(65, 'Lock product image', 'Locking product image', '0000-00-00 00:00:00', '2013-05-19 20:34:52', NULL, 1, NULL, NULL),
(66, 'Add Product Prices', 'Add/update product prices', '0000-00-00 00:00:00', '2013-05-22 04:54:25', NULL, 1, NULL, NULL),
(67, 'Add Product Categories', 'Add/update product categories', '0000-00-00 00:00:00', '2013-05-22 11:12:48', NULL, 1, NULL, NULL),
(68, 'Add Product Attribute Values', 'Add/update product attribute values', '0000-00-00 00:00:00', '2013-05-27 07:08:30', NULL, 1, NULL, NULL),
(69, 'Update Product', 'Editing product details', '0000-00-00 00:00:00', '2013-05-27 11:00:39', NULL, 1, NULL, NULL),
(70, 'Lock product', 'Locking product', '0000-00-00 00:00:00', '2013-06-08 02:56:08', NULL, 1, NULL, NULL),
(71, 'Unlock product', 'Unlocking a product', '0000-00-00 00:00:00', '2013-06-08 02:56:08', NULL, 1, NULL, NULL),
(72, 'Delete product', 'Deleting product', '0000-00-00 00:00:00', '2013-06-08 02:56:08', NULL, 1, NULL, NULL);

-- --------------------------------------------------------

--
-- Table structure for table `apmpasswordhistory`
--

CREATE TABLE IF NOT EXISTS `apmpasswordhistory` (
  `psid` int(11) NOT NULL AUTO_INCREMENT COMMENT 'primary key for password history',
  `userid` int(11) NOT NULL COMMENT 'user id as a foreign key',
  `userpassword` varchar(255) NOT NULL COMMENT 'user password',
  `createddatetime` datetime NOT NULL COMMENT 'record created date time',
  `deleteddatetime` datetime DEFAULT NULL COMMENT 'record deleted date time',
  `updateddatetime` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'record updated date time',
  `statusid` int(11) NOT NULL COMMENT 'record status as a foreign key from apmmasterrecordsstate',
  `createdby` varchar(255) DEFAULT NULL COMMENT 'Stores MySQL User Created Details',
  `lastupdatedby` varchar(255) DEFAULT NULL COMMENT 'Stores MySQL User last updated Details',
  PRIMARY KEY (`psid`),
  KEY `FK_apmpasswordhistory_statusid_apmmasterrecordsstate` (`statusid`),
  KEY `FK_apmpasswordhistory_userid_apmusers` (`userid`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 COMMENT='password history maintenance' AUTO_INCREMENT=384 ;

--
-- Dumping data for table `apmpasswordhistory`
--

INSERT INTO `apmpasswordhistory` (`psid`, `userid`, `userpassword`, `createddatetime`, `deleteddatetime`, `updateddatetime`, `statusid`, `createdby`, `lastupdatedby`) VALUES
(378, 83, 'd91a8e1eda7711e21c1a92c3d84dd906167f4188fc5a42ac0f30740aea08655b', '2013-06-02 13:55:29', NULL, '2013-06-02 08:48:51', 2, NULL, NULL),
(379, 83, '07480fb9e85b9396af06f006cf1c95024af2531c65fb505cfbd0add1e2f31573', '2013-06-02 14:18:51', NULL, '2013-06-02 08:48:51', 1, NULL, NULL),
(380, 84, '890fb10e10ce0b0e42da99b80726d44fb44ae64cdb8a7673a22d481963cfaff1', '2013-06-02 14:26:02', NULL, '2013-06-02 09:41:13', 2, NULL, NULL),
(381, 84, '07480fb9e85b9396af06f006cf1c95024af2531c65fb505cfbd0add1e2f31573', '2013-06-02 15:11:13', NULL, '2013-06-02 09:41:13', 1, NULL, NULL),
(382, 85, '4c5248c642713ed08c638489f7eac8bb11b0ea83ed646604fb5ac9fccd9c2cb8', '2013-06-02 15:15:52', NULL, '2013-06-02 09:47:21', 2, NULL, NULL),
(383, 85, '07480fb9e85b9396af06f006cf1c95024af2531c65fb505cfbd0add1e2f31573', '2013-06-02 15:17:21', NULL, '2013-06-02 09:47:21', 1, NULL, NULL);

-- --------------------------------------------------------

--
-- Table structure for table `apmsecurityqa`
--

CREATE TABLE IF NOT EXISTS `apmsecurityqa` (
  `answerid` int(11) NOT NULL AUTO_INCREMENT COMMENT 'primary key for security question answers',
  `userid` int(11) NOT NULL COMMENT 'user for which the questions are assigned',
  `securityquestionid` int(11) NOT NULL DEFAULT '0' COMMENT 'question id as a foreign key from apmmastersecurityquestions table',
  `securityquestion` varchar(60) DEFAULT NULL COMMENT 'Customized security question entered by the user',
  `answer` varchar(255) CHARACTER SET latin1 NOT NULL COMMENT 'encrypted answer for the selected question',
  `createddatetime` datetime NOT NULL COMMENT 'record created date time',
  `updateddatetime` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'record updated date time',
  `deleteddatetime` datetime DEFAULT NULL COMMENT 'record deleted date time',
  `statusid` int(11) NOT NULL COMMENT 'record status as aforeign key from the apmmasterrecordsstate table',
  `createdby` varchar(255) DEFAULT NULL COMMENT 'Stores MySQL User Created Details',
  `lastupdatedby` varchar(255) DEFAULT NULL COMMENT 'Stores MySQL User last updated Details',
  PRIMARY KEY (`answerid`),
  KEY `FK_apmsecurityquestionanswers_statusid_apmmasterrecordsstate` (`statusid`),
  KEY `FK_apmsecurityqa_userid_apmusers` (`userid`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 COMMENT='answers for security questions are saved here' AUTO_INCREMENT=48 ;

--
-- Dumping data for table `apmsecurityqa`
--

INSERT INTO `apmsecurityqa` (`answerid`, `userid`, `securityquestionid`, `securityquestion`, `answer`, `createddatetime`, `updateddatetime`, `deleteddatetime`, `statusid`, `createdby`, `lastupdatedby`) VALUES
(45, 83, 0, 'q1', 'd9d81b76a6ae5f5640b9fc88a8b04dba372c5c4aaead621db6d89ab8f5e45726', '2013-06-02 14:18:52', '2013-06-02 08:48:52', NULL, 1, NULL, NULL),
(46, 84, 0, 'q1', 'd9d81b76a6ae5f5640b9fc88a8b04dba372c5c4aaead621db6d89ab8f5e45726', '2013-06-02 15:11:14', '2013-06-02 09:41:14', NULL, 1, NULL, NULL),
(47, 85, 0, 'q1', 'd9d81b76a6ae5f5640b9fc88a8b04dba372c5c4aaead621db6d89ab8f5e45726', '2013-06-02 15:17:22', '2013-06-02 09:47:22', NULL, 1, NULL, NULL);

-- --------------------------------------------------------

--
-- Table structure for table `apmsessiondata`
--

CREATE TABLE IF NOT EXISTS `apmsessiondata` (
  `sessid` varchar(32) NOT NULL COMMENT 'session id of a user is noted here',
  `sesshttpuseragent` varchar(32) NOT NULL COMMENT 'User ip information',
  `sessdata` blob NOT NULL COMMENT 'session data of a user',
  `sessexpire` int(11) NOT NULL DEFAULT '0' COMMENT 'Session Expiry time',
  `createddatetime` datetime NOT NULL COMMENT 'record created date time',
  `deleteddatetime` datetime DEFAULT NULL COMMENT 'record deleted time',
  `updateddatetime` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'record updated date time',
  `createdby` varchar(255) DEFAULT NULL COMMENT 'Stores MySQL User Created Details',
  `lastupdatedby` varchar(255) DEFAULT NULL COMMENT 'Stores MySQL User last updated Details',
  PRIMARY KEY (`sessid`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Stores session data for each application user login';

--
-- Dumping data for table `apmsessiondata`
--

INSERT INTO `apmsessiondata` (`sessid`, `sesshttpuseragent`, `sessdata`, `sessexpire`, `createddatetime`, `deleteddatetime`, `updateddatetime`, `createdby`, `lastupdatedby`) VALUES
('01rvqrd3smptd0rt96g7mi6mh0', '5c8a8ffed19567e500dc1d7127309813', '', 1367994967, '2013-05-08 11:07:08', NULL, '2013-05-08 05:37:08', NULL, NULL),
('0uefiouvq8e5m2io0slju9eoj7', '3cf4c23e4201565642bf5b496a65f13e', 0x4d79506f7274616c7c613a363a7b733a333a22617070223b733a353a2261646d696e223b733a31393a2269734a617661736372697074456e61626c6564223b693a303b733a31313a22656d7074796c61796f7574223b733a31373a2261646d696e2f656d7074796c61796f7574223b733a363a226c61796f7574223b733a31323a2261646d696e2f6c61796f7574223b733a373a226661696c757265223b4e3b733a373a2273756363657373223b4e3b7d6164646d65726368616e747c613a313a7b733a373a2273756363657373223b4e3b7d, 1365271435, '2013-04-06 23:30:56', NULL, '2013-04-06 18:00:56', NULL, NULL),
('1lbkc1l4vedn6glr5o1d4idvc3', 'df3025e157f07d8defd08d0fb7c5843f', 0x4d79506f7274616c7c613a32313a7b733a383a226c6f67676564496e223b693a313b733a333a22617070223b733a353a2261646d696e223b733a31303a2266697273746c6f67696e223b733a313a2231223b733a31353a227365637572697479656e61626c6564223b733a313a2231223b733a31393a2269734a617661736372697074456e61626c6564223b693a303b733a31313a22656d7074796c61796f7574223b733a31373a2261646d696e2f656d7074796c61796f7574223b733a363a226c61796f7574223b733a31323a2261646d696e2f6c61796f7574223b733a373a226661696c757265223b4e3b733a373a2273756363657373223b4e3b733a31353a2270617373776f726445787069726564223b733a313a2232223b733a383a227573657274797065223b733a303a22223b733a343a22726f6c65223b733a31303a22537570657261646d696e223b733a383a22757365726e616d65223b733a393a2268656d612b76617375223b733a31303a2275736572747970656964223b4e3b733a363a22726f6c656964223b733a313a2235223b733a363a22757365726964223b733a323a223634223b733a393a2275736572656d61696c223b733a32303a227661737568656d612534307961686f6f2e636f6d223b733a383a227072696f72697479223b733a313a2231223b733a31313a22757365726c6f67696e6964223b733a31383a227661737568656d61407961686f6f2e636f6d223b733a32313a22726573657470617373776f72647265717569726564223b693a313b733a31333a2276616c69646174656572726f72223b4e3b7d6164646d65726368616e747c613a313a7b733a373a2273756363657373223b4e3b7d, 1365082377, '2013-04-04 17:25:28', NULL, '2013-04-04 13:29:58', NULL, NULL),
('1u2mtetfmnjmkc0962na8sokt2', 'd18e6bdfae14d5729064b3312d223e11', 0x4d79506f7274616c7c613a32313a7b733a333a22617070223b733a353a2261646d696e223b733a31393a2269734a617661736372697074456e61626c6564223b693a303b733a31313a22656d7074796c61796f7574223b733a31373a2261646d696e2f656d7074796c61796f7574223b733a363a226c61796f7574223b733a31323a2261646d696e2f6c61796f7574223b733a373a226661696c757265223b4e3b733a373a2273756363657373223b4e3b733a31353a2270617373776f726445787069726564223b733a313a2232223b733a383a226c6f67676564496e223b693a313b733a383a227573657274797065223b733a303a22223b733a343a22726f6c65223b733a31303a22537570657261646d696e223b733a383a22757365726e616d65223b733a31343a22537570657241646d696e2b474747223b733a31303a2275736572747970656964223b4e3b733a363a22726f6c656964223b733a313a2235223b733a363a22757365726964223b733a323a223634223b733a393a2275736572656d61696c223b733a32323a22737570657261646d696e253430676d61696c2e636f6d223b733a383a227072696f72697479223b733a313a2231223b733a31313a22757365726c6f67696e6964223b733a32303a22737570657261646d696e40676d61696c2e636f6d223b733a31303a2266697273746c6f67696e223b733a313a2230223b733a31353a227365637572697479656e61626c6564223b733a313a2231223b733a32313a22726573657470617373776f72647265717569726564223b693a313b733a31333a2276616c69646174656572726f72223b4e3b7d6164646d65726368616e747c613a313a7b733a373a2273756363657373223b4e3b7d, 1367215205, '2013-04-29 10:30:18', NULL, '2013-04-29 05:01:07', NULL, NULL),
('23b6o4lugh21fn5msnkmh70sa4', '5c8a8ffed19567e500dc1d7127309813', 0x4d79506f7274616c7c613a32313a7b733a333a22617070223b733a353a2261646d696e223b733a31393a2269734a617661736372697074456e61626c6564223b693a303b733a31313a22656d7074796c61796f7574223b733a31373a2261646d696e2f656d7074796c61796f7574223b733a363a226c61796f7574223b733a31323a2261646d696e2f6c61796f7574223b733a373a226661696c757265223b4e3b733a373a2273756363657373223b4e3b733a31353a2270617373776f726445787069726564223b733a313a2232223b733a383a226c6f67676564496e223b693a313b733a383a227573657274797065223b733a303a22223b733a343a22726f6c65223b733a31303a22537570657261646d696e223b733a383a22757365726e616d65223b733a31343a22537570657241646d696e2b474747223b733a31303a2275736572747970656964223b4e3b733a363a22726f6c656964223b733a313a2235223b733a363a22757365726964223b733a323a223634223b733a393a2275736572656d61696c223b733a32323a22737570657261646d696e253430676d61696c2e636f6d223b733a383a227072696f72697479223b733a313a2231223b733a31313a22757365726c6f67696e6964223b733a32303a22737570657261646d696e40676d61696c2e636f6d223b733a31303a2266697273746c6f67696e223b733a313a2230223b733a31353a227365637572697479656e61626c6564223b733a313a2231223b733a32313a22726573657470617373776f72647265717569726564223b693a313b733a31333a2276616c69646174656572726f72223b4e3b7d6164646d65726368616e747c613a313a7b733a373a2273756363657373223b4e3b7d, 1368515079, '2013-05-14 11:09:47', NULL, '2013-05-14 06:05:40', NULL, NULL),
('2gtm6djvnm460lft0a4bioe653', '5c8a8ffed19567e500dc1d7127309813', 0x4d79506f7274616c7c613a32313a7b733a333a22617070223b733a353a2261646d696e223b733a31303a2266697273746c6f67696e223b733a313a2230223b733a31353a227365637572697479656e61626c6564223b733a313a2231223b733a383a226c6f67676564496e223b693a313b733a31393a2269734a617661736372697074456e61626c6564223b693a303b733a31313a22656d7074796c61796f7574223b733a31373a2261646d696e2f656d7074796c61796f7574223b733a363a226c61796f7574223b733a31323a2261646d696e2f6c61796f7574223b733a373a226661696c757265223b4e3b733a373a2273756363657373223b733a303a22223b733a31353a2270617373776f726445787069726564223b733a313a2232223b733a383a227573657274797065223b733a303a22223b733a343a22726f6c65223b733a31303a22537570657261646d696e223b733a383a22757365726e616d65223b733a31343a22537570657241646d696e2b474747223b733a31303a2275736572747970656964223b4e3b733a363a22726f6c656964223b733a313a2235223b733a363a22757365726964223b733a323a223634223b733a393a2275736572656d61696c223b733a32323a22737570657261646d696e253430676d61696c2e636f6d223b733a383a227072696f72697479223b733a313a2231223b733a31313a22757365726c6f67696e6964223b733a32303a22737570657261646d696e40676d61696c2e636f6d223b733a32313a22726573657470617373776f72647265717569726564223b693a313b733a31333a2276616c69646174656572726f72223b733a31353a22496e76616c69642055736572204944223b7d6164646d65726368616e747c613a313a7b733a373a2273756363657373223b4e3b7d, 1366117160, '2013-04-16 11:06:38', NULL, '2013-04-16 12:49:21', NULL, NULL),
('2pcv1sls5m2l3p5jahsuel14m7', '34b4bebc862c31642714199c925cabcc', 0x4d79506f7274616c7c613a32313a7b733a333a22617070223b733a353a2261646d696e223b733a31303a2266697273746c6f67696e223b733a313a2230223b733a31353a227365637572697479656e61626c6564223b733a313a2231223b733a383a226c6f67676564496e223b693a313b733a31393a2269734a617661736372697074456e61626c6564223b693a303b733a31313a22656d7074796c61796f7574223b733a31373a2261646d696e2f656d7074796c61796f7574223b733a363a226c61796f7574223b733a31323a2261646d696e2f6c61796f7574223b733a373a226661696c757265223b4e3b733a373a2273756363657373223b733a303a22223b733a31353a2270617373776f726445787069726564223b733a313a2232223b733a383a227573657274797065223b733a303a22223b733a343a22726f6c65223b733a31303a22537570657261646d696e223b733a383a22757365726e616d65223b733a31343a22537570657241646d696e2b474747223b733a31303a2275736572747970656964223b4e3b733a363a22726f6c656964223b733a313a2235223b733a363a22757365726964223b733a323a223634223b733a393a2275736572656d61696c223b733a32323a22737570657261646d696e253430676d61696c2e636f6d223b733a383a227072696f72697479223b733a313a2231223b733a31313a22757365726c6f67696e6964223b733a32303a22737570657261646d696e40676d61696c2e636f6d223b733a32313a22726573657470617373776f72647265717569726564223b693a313b733a31333a2276616c69646174656572726f72223b4e3b7d6164646d65726368616e747c613a313a7b733a373a2273756363657373223b4e3b7d, 1369230457, '2013-05-22 10:19:22', NULL, '2013-05-22 12:48:38', NULL, NULL),
('31lmk4l5purbnvro3u2q180b21', '2e8b7796206c78ec6ff743ba4df79a4d', 0x4d79506f7274616c7c613a363a7b733a333a22617070223b733a353a2261646d696e223b733a31393a2269734a617661736372697074456e61626c6564223b693a303b733a31313a22656d7074796c61796f7574223b733a31373a2261646d696e2f656d7074796c61796f7574223b733a363a226c61796f7574223b733a31323a2261646d696e2f6c61796f7574223b733a373a226661696c757265223b4e3b733a373a2273756363657373223b4e3b7d6164646d65726368616e747c613a313a7b733a373a2273756363657373223b4e3b7d, 1370172217, '2013-06-02 13:08:49', NULL, '2013-06-02 10:24:38', NULL, NULL),
('522i30n6n0gnnbea4lfg8pabu3', '3cf4c23e4201565642bf5b496a65f13e', 0x4d79506f7274616c7c613a32313a7b733a333a22617070223b733a353a2261646d696e223b733a31303a2266697273746c6f67696e223b733a313a2230223b733a31353a227365637572697479656e61626c6564223b733a313a2231223b733a383a226c6f67676564496e223b693a313b733a31393a2269734a617661736372697074456e61626c6564223b693a303b733a31313a22656d7074796c61796f7574223b733a31373a2261646d696e2f656d7074796c61796f7574223b733a363a226c61796f7574223b733a31323a2261646d696e2f6c61796f7574223b733a373a226661696c757265223b4e3b733a373a2273756363657373223b4e3b733a31353a2270617373776f726445787069726564223b733a313a2232223b733a383a227573657274797065223b733a303a22223b733a343a22726f6c65223b733a31303a22537570657261646d696e223b733a383a22757365726e616d65223b733a31333a22537570657241646d696e2b4747223b733a31303a2275736572747970656964223b4e3b733a363a22726f6c656964223b733a313a2235223b733a363a22757365726964223b733a323a223634223b733a393a2275736572656d61696c223b733a32323a22737570657261646d696e253430676d61696c2e636f6d223b733a383a227072696f72697479223b733a313a2231223b733a31313a22757365726c6f67696e6964223b733a32303a22737570657261646d696e40676d61696c2e636f6d223b733a32313a22726573657470617373776f72647265717569726564223b693a303b733a31333a2276616c69646174656572726f72223b4e3b7d6164646d65726368616e747c613a313a7b733a373a2273756363657373223b4e3b7d, 1365353321, '2013-04-07 22:06:44', NULL, '2013-04-07 16:45:42', NULL, NULL),
('5mhjen48u9ish18seteb7bgpd3', '3cf4c23e4201565642bf5b496a65f13e', 0x4d79506f7274616c7c613a363a7b733a333a22617070223b733a353a2261646d696e223b733a31393a2269734a617661736372697074456e61626c6564223b693a303b733a31313a22656d7074796c61796f7574223b733a31373a2261646d696e2f656d7074796c61796f7574223b733a363a226c61796f7574223b733a31323a2261646d696e2f6c61796f7574223b733a373a226661696c757265223b4e3b733a373a2273756363657373223b4e3b7d6164646d65726368616e747c613a313a7b733a373a2273756363657373223b4e3b7d, 1365271237, '2013-04-06 22:28:57', NULL, '2013-04-06 17:57:38', NULL, NULL),
('6bp0hcthts538ekreqqih411d1', 'df3025e157f07d8defd08d0fb7c5843f', 0x4d79506f7274616c7c613a32313a7b733a333a22617070223b733a353a2261646d696e223b733a383a226c6f67676564496e223b693a313b733a31393a2269734a617661736372697074456e61626c6564223b693a303b733a31313a22656d7074796c61796f7574223b733a31373a2261646d696e2f656d7074796c61796f7574223b733a363a226c61796f7574223b733a31323a2261646d696e2f6c61796f7574223b733a373a226661696c757265223b4e3b733a373a2273756363657373223b733a303a22223b733a31353a2270617373776f726445787069726564223b733a313a2232223b733a383a227573657274797065223b733a303a22223b733a343a22726f6c65223b733a31303a22537570657261646d696e223b733a383a22757365726e616d65223b733a31323a22537570657241646d696e2b47223b733a31303a2275736572747970656964223b4e3b733a363a22726f6c656964223b733a313a2235223b733a363a22757365726964223b733a323a223634223b733a393a2275736572656d61696c223b733a32323a22737570657261646d696e253430676d61696c2e636f6d223b733a383a227072696f72697479223b733a313a2231223b733a31313a22757365726c6f67696e6964223b733a32303a22737570657261646d696e40676d61696c2e636f6d223b733a31303a2266697273746c6f67696e223b733a313a2231223b733a31353a227365637572697479656e61626c6564223b733a313a2231223b733a32313a22726573657470617373776f72647265717569726564223b693a303b733a31333a2276616c69646174656572726f72223b4e3b7d6164646d65726368616e747c613a313a7b733a373a2273756363657373223b4e3b7d, 1365164912, '2013-04-05 16:15:26', NULL, '2013-04-05 12:25:33', NULL, NULL),
('6uni9dd5vvqq6deuk019d6jjj1', '34b4bebc862c31642714199c925cabcc', 0x6164646d65726368616e747c613a313a7b733a373a2273756363657373223b4e3b7d4d79506f7274616c7c613a32303a7b733a333a22617070223b733a353a2261646d696e223b733a31393a2269734a617661736372697074456e61626c6564223b693a303b733a31313a22656d7074796c61796f7574223b733a31373a2261646d696e2f656d7074796c61796f7574223b733a363a226c61796f7574223b733a31323a2261646d696e2f6c61796f7574223b733a373a226661696c757265223b4e3b733a373a2273756363657373223b4e3b733a31353a2270617373776f726445787069726564223b733a313a2232223b733a383a226c6f67676564496e223b693a313b733a383a227573657274797065223b733a303a22223b733a343a22726f6c65223b733a31303a22537570657261646d696e223b733a383a22757365726e616d65223b733a31343a22537570657261646d696e2b54776f223b733a31303a2275736572747970656964223b4e3b733a363a22726f6c656964223b733a313a2235223b733a363a22757365726964223b733a323a223832223b733a393a2275736572656d61696c223b733a32333a22737570657261646d696e32253430676d61696c2e636f6d223b733a383a227072696f72697479223b733a313a2231223b733a31313a22757365726c6f67696e6964223b733a32313a22737570657261646d696e3240676d61696c2e636f6d223b733a31303a2266697273746c6f67696e223b733a313a2231223b733a31353a227365637572697479656e61626c6564223b733a313a2230223b733a32313a22726573657470617373776f72647265717569726564223b693a303b7d, 1370164407, '2013-06-02 12:11:38', NULL, '2013-06-02 08:14:28', NULL, NULL),
('6v91a79hai1vjp47548lnk6r67', '5c8a8ffed19567e500dc1d7127309813', 0x4d79506f7274616c7c613a32313a7b733a333a22617070223b733a353a2261646d696e223b733a31393a2269734a617661736372697074456e61626c6564223b693a303b733a31313a22656d7074796c61796f7574223b733a31373a2261646d696e2f656d7074796c61796f7574223b733a363a226c61796f7574223b733a31323a2261646d696e2f6c61796f7574223b733a373a226661696c757265223b4e3b733a373a2273756363657373223b4e3b733a31353a2270617373776f726445787069726564223b733a313a2232223b733a383a226c6f67676564496e223b693a313b733a383a227573657274797065223b733a303a22223b733a343a22726f6c65223b733a31303a22537570657261646d696e223b733a383a22757365726e616d65223b733a31343a22537570657241646d696e2b474747223b733a31303a2275736572747970656964223b4e3b733a363a22726f6c656964223b733a313a2235223b733a363a22757365726964223b733a323a223634223b733a393a2275736572656d61696c223b733a32323a22737570657261646d696e253430676d61696c2e636f6d223b733a383a227072696f72697479223b733a313a2231223b733a31313a22757365726c6f67696e6964223b733a32303a22737570657261646d696e40676d61696c2e636f6d223b733a31303a2266697273746c6f67696e223b733a313a2230223b733a31353a227365637572697479656e61626c6564223b733a313a2231223b733a32313a22726573657470617373776f72647265717569726564223b693a313b733a31333a2276616c69646174656572726f72223b4e3b7d6164646d65726368616e747c613a313a7b733a373a2273756363657373223b4e3b7d, 1368907664, '2013-05-18 23:50:17', NULL, '2013-05-18 19:08:45', NULL, NULL),
('77ies86sfmlb67r20aaadrd6l5', '3cf4c23e4201565642bf5b496a65f13e', 0x4d79506f7274616c7c613a363a7b733a333a22617070223b733a353a2261646d696e223b733a31393a2269734a617661736372697074456e61626c6564223b693a303b733a31313a22656d7074796c61796f7574223b733a31373a2261646d696e2f656d7074796c61796f7574223b733a363a226c61796f7574223b733a31323a2261646d696e2f6c61796f7574223b733a373a226661696c757265223b4e3b733a373a2273756363657373223b4e3b7d6164646d65726368616e747c613a313a7b733a373a2273756363657373223b4e3b7d, 1365267639, '2013-04-06 22:24:19', NULL, '2013-04-06 16:57:40', NULL, NULL),
('7t74h3ctjnu6tckda6o4subbf5', '5c8a8ffed19567e500dc1d7127309813', '', 1366038406, '2013-04-14 17:33:27', NULL, '2013-04-15 14:56:47', NULL, NULL),
('89vpnekajed03vlhr7l565bgg6', 'd18e6bdfae14d5729064b3312d223e11', 0x4d79506f7274616c7c613a32313a7b733a333a22617070223b733a353a2261646d696e223b733a31393a2269734a617661736372697074456e61626c6564223b693a303b733a31313a22656d7074796c61796f7574223b733a31373a2261646d696e2f656d7074796c61796f7574223b733a363a226c61796f7574223b733a31323a2261646d696e2f6c61796f7574223b733a373a226661696c757265223b4e3b733a373a2273756363657373223b733a303a22223b733a31353a2270617373776f726445787069726564223b733a313a2232223b733a383a226c6f67676564496e223b693a313b733a383a227573657274797065223b733a303a22223b733a343a22726f6c65223b733a31303a22537570657261646d696e223b733a383a22757365726e616d65223b733a31343a22537570657241646d696e2b474747223b733a31303a2275736572747970656964223b4e3b733a363a22726f6c656964223b733a313a2235223b733a363a22757365726964223b733a323a223634223b733a393a2275736572656d61696c223b733a32323a22737570657261646d696e253430676d61696c2e636f6d223b733a383a227072696f72697479223b733a313a2231223b733a31313a22757365726c6f67696e6964223b733a32303a22737570657261646d696e40676d61696c2e636f6d223b733a31303a2266697273746c6f67696e223b733a313a2230223b733a31353a227365637572697479656e61626c6564223b733a313a2231223b733a32313a22726573657470617373776f72647265717569726564223b693a313b733a31333a2276616c69646174656572726f72223b733a32363a224572726f725f496e76616c69645f4174747269627574655f4964223b7d6164646d65726368616e747c613a313a7b733a373a2273756363657373223b4e3b7d, 1366488013, '2013-04-20 19:59:35', NULL, '2013-04-20 19:01:14', NULL, NULL),
('94iee2rqlv8seeba8t9c4bkqo7', 'd18e6bdfae14d5729064b3312d223e11', 0x4d79506f7274616c7c613a32323a7b733a333a22617070223b733a353a2261646d696e223b733a31393a2269734a617661736372697074456e61626c6564223b693a303b733a31313a22656d7074796c61796f7574223b733a31373a2261646d696e2f656d7074796c61796f7574223b733a363a226c61796f7574223b733a31323a2261646d696e2f6c61796f7574223b733a373a226661696c757265223b4e3b733a373a2273756363657373223b733a303a22223b733a31353a2270617373776f726445787069726564223b733a313a2232223b733a383a226c6f67676564496e223b693a313b733a383a227573657274797065223b733a303a22223b733a343a22726f6c65223b733a31303a22537570657261646d696e223b733a383a22757365726e616d65223b733a31343a22537570657241646d696e2b474747223b733a31303a2275736572747970656964223b4e3b733a363a22726f6c656964223b733a313a2235223b733a363a22757365726964223b733a323a223634223b733a393a2275736572656d61696c223b733a32323a22737570657261646d696e253430676d61696c2e636f6d223b733a383a227072696f72697479223b733a313a2231223b733a31313a22757365726c6f67696e6964223b733a32303a22737570657261646d696e40676d61696c2e636f6d223b733a31303a2266697273746c6f67696e223b733a313a2230223b733a31353a227365637572697479656e61626c6564223b733a313a2231223b733a32313a22726573657470617373776f72647265717569726564223b693a313b733a31333a2276616c69646174656572726f72223b4e3b733a383a22726573656c6c6572223b4e3b7d6164646d65726368616e747c613a313a7b733a373a2273756363657373223b4e3b7d, 1366999420, '2013-04-26 21:43:16', NULL, '2013-04-26 17:04:41', NULL, NULL),
('9ap4gtt8u95elf15n8dog2k8l2', '34b4bebc862c31642714199c925cabcc', 0x6164646d65726368616e747c613a313a7b733a373a2273756363657373223b4e3b7d4d79506f7274616c7c613a32313a7b733a333a22617070223b733a353a2261646d696e223b733a31393a2269734a617661736372697074456e61626c6564223b693a303b733a31313a22656d7074796c61796f7574223b733a31373a2261646d696e2f656d7074796c61796f7574223b733a363a226c61796f7574223b733a31323a2261646d696e2f6c61796f7574223b733a373a226661696c757265223b4e3b733a373a2273756363657373223b733a303a22223b733a31353a2270617373776f726445787069726564223b733a313a2232223b733a383a226c6f67676564496e223b693a313b733a383a227573657274797065223b733a303a22223b733a343a22726f6c65223b733a31303a22537570657261646d696e223b733a383a22757365726e616d65223b733a31343a22537570657241646d696e2b474747223b733a31303a2275736572747970656964223b4e3b733a363a22726f6c656964223b733a313a2235223b733a363a22757365726964223b733a323a223634223b733a393a2275736572656d61696c223b733a32323a22737570657261646d696e253430676d61696c2e636f6d223b733a383a227072696f72697479223b733a313a2231223b733a31313a22757365726c6f67696e6964223b733a32303a22737570657261646d696e40676d61696c2e636f6d223b733a31303a2266697273746c6f67696e223b733a313a2230223b733a31353a227365637572697479656e61626c6564223b733a313a2231223b733a32313a22726573657470617373776f72647265717569726564223b693a313b733a31333a2276616c69646174656572726f72223b4e3b7d, 1369658672, '2013-05-27 09:47:30', NULL, '2013-05-27 11:45:33', NULL, NULL),
('a108p5ag4avu1uq3pabgog5kq2', '34b4bebc862c31642714199c925cabcc', 0x4d79506f7274616c7c613a32313a7b733a333a22617070223b733a353a2261646d696e223b733a31303a2266697273746c6f67696e223b733a313a2230223b733a31353a227365637572697479656e61626c6564223b733a313a2231223b733a383a226c6f67676564496e223b693a313b733a31393a2269734a617661736372697074456e61626c6564223b693a303b733a31313a22656d7074796c61796f7574223b733a31373a2261646d696e2f656d7074796c61796f7574223b733a363a226c61796f7574223b733a31323a2261646d696e2f6c61796f7574223b733a373a226661696c757265223b4e3b733a373a2273756363657373223b4e3b733a31353a2270617373776f726445787069726564223b733a313a2232223b733a383a227573657274797065223b733a303a22223b733a343a22726f6c65223b733a31303a22537570657261646d696e223b733a383a22757365726e616d65223b733a31343a22537570657241646d696e2b474747223b733a31303a2275736572747970656964223b4e3b733a363a22726f6c656964223b733a313a2235223b733a363a22757365726964223b733a323a223634223b733a393a2275736572656d61696c223b733a32323a22737570657261646d696e253430676d61696c2e636f6d223b733a383a227072696f72697479223b733a313a2231223b733a31313a22757365726c6f67696e6964223b733a32303a22737570657261646d696e40676d61696c2e636f6d223b733a32313a22726573657470617373776f72647265717569726564223b693a313b733a31333a2276616c69646174656572726f72223b4e3b7d6164646d65726368616e747c613a313a7b733a373a2273756363657373223b4e3b7d, 1369140070, '2013-05-21 15:08:51', NULL, '2013-05-21 11:42:11', NULL, NULL),
('a6ocgaoc1u8rk1gu5t2ivrsg83', '34b4bebc862c31642714199c925cabcc', 0x4d79506f7274616c7c613a32303a7b733a333a22617070223b733a353a2261646d696e223b733a31393a2269734a617661736372697074456e61626c6564223b693a303b733a31313a22656d7074796c61796f7574223b733a31373a2261646d696e2f656d7074796c61796f7574223b733a363a226c61796f7574223b733a31323a2261646d696e2f6c61796f7574223b733a373a226661696c757265223b4e3b733a373a2273756363657373223b4e3b733a31353a2270617373776f726445787069726564223b733a313a2232223b733a383a226c6f67676564496e223b693a313b733a383a227573657274797065223b733a303a22223b733a343a22726f6c65223b733a31303a22537570657261646d696e223b733a383a22757365726e616d65223b733a31343a22537570657241646d696e2b474747223b733a31303a2275736572747970656964223b4e3b733a363a22726f6c656964223b733a313a2235223b733a363a22757365726964223b733a323a223634223b733a393a2275736572656d61696c223b733a32323a22737570657261646d696e253430676d61696c2e636f6d223b733a383a227072696f72697479223b733a313a2231223b733a31313a22757365726c6f67696e6964223b733a32303a22737570657261646d696e40676d61696c2e636f6d223b733a31303a2266697273746c6f67696e223b733a313a2230223b733a31353a227365637572697479656e61626c6564223b733a313a2231223b733a32313a22726573657470617373776f72647265717569726564223b693a313b7d6164646d65726368616e747c613a313a7b733a373a2273756363657373223b4e3b7d, 1370158602, '2013-06-02 12:06:18', NULL, '2013-06-02 06:37:43', NULL, NULL),
('am8a97me7vofkpdhhger2nikg3', '3cf4c23e4201565642bf5b496a65f13e', 0x4d79506f7274616c7c613a363a7b733a333a22617070223b733a353a2261646d696e223b733a31393a2269734a617661736372697074456e61626c6564223b693a303b733a31313a22656d7074796c61796f7574223b733a31373a2261646d696e2f656d7074796c61796f7574223b733a363a226c61796f7574223b733a31323a2261646d696e2f6c61796f7574223b733a373a226661696c757265223b4e3b733a373a2273756363657373223b4e3b7d6164646d65726368616e747c613a313a7b733a373a2273756363657373223b4e3b7d, 1365271435, '2013-04-06 23:30:56', NULL, '2013-04-06 18:00:56', NULL, NULL),
('au67j9gu58us1n2k3pleol8hq1', '3cf4c23e4201565642bf5b496a65f13e', 0x4d79506f7274616c7c613a363a7b733a333a22617070223b733a353a2261646d696e223b733a31393a2269734a617661736372697074456e61626c6564223b693a303b733a31313a22656d7074796c61796f7574223b733a31373a2261646d696e2f656d7074796c61796f7574223b733a363a226c61796f7574223b733a31323a2261646d696e2f6c61796f7574223b733a373a226661696c757265223b4e3b733a373a2273756363657373223b4e3b7d6164646d65726368616e747c613a313a7b733a373a2273756363657373223b4e3b7d, 1365271548, '2013-04-06 23:30:56', NULL, '2013-04-06 18:02:49', NULL, NULL),
('bf79ku14ec307hg8vtk4r6t925', 'a5f724d1b119d6198c6e59fe73fc0807', 0x4d79506f7274616c7c613a333a7b733a333a22617070223b4e3b733a31303a2266697273746c6f67696e223b4e3b733a31353a227365637572697479656e61626c6564223b4e3b7d, 1365264749, '2013-04-06 20:04:27', NULL, '2013-04-06 16:09:30', NULL, NULL),
('bgev2bpjgtlsuo0t2ncvi51t45', 'd18e6bdfae14d5729064b3312d223e11', 0x4d79506f7274616c7c613a32313a7b733a333a22617070223b733a353a2261646d696e223b733a31393a2269734a617661736372697074456e61626c6564223b693a303b733a31313a22656d7074796c61796f7574223b733a31373a2261646d696e2f656d7074796c61796f7574223b733a363a226c61796f7574223b733a31323a2261646d696e2f6c61796f7574223b733a373a226661696c757265223b4e3b733a373a2273756363657373223b4e3b733a31353a2270617373776f726445787069726564223b733a313a2232223b733a383a226c6f67676564496e223b693a313b733a383a227573657274797065223b733a303a22223b733a343a22726f6c65223b733a31303a22537570657261646d696e223b733a383a22757365726e616d65223b733a31343a22537570657241646d696e2b474747223b733a31303a2275736572747970656964223b4e3b733a363a22726f6c656964223b733a313a2235223b733a363a22757365726964223b733a323a223634223b733a393a2275736572656d61696c223b733a32323a22737570657261646d696e253430676d61696c2e636f6d223b733a383a227072696f72697479223b733a313a2231223b733a31313a22757365726c6f67696e6964223b733a32303a22737570657261646d696e40676d61696c2e636f6d223b733a31303a2266697273746c6f67696e223b733a313a2230223b733a31353a227365637572697479656e61626c6564223b733a313a2231223b733a32313a22726573657470617373776f72647265717569726564223b693a313b733a31333a2276616c69646174656572726f72223b4e3b7d6164646d65726368616e747c613a313a7b733a373a2273756363657373223b4e3b7d, 1367173885, '2013-04-28 21:14:12', NULL, '2013-04-28 17:32:26', NULL, NULL),
('bpt9hhk5uh42st78nkru55lmh6', 'd18e6bdfae14d5729064b3312d223e11', 0x4d79506f7274616c7c613a32303a7b733a333a22617070223b733a353a2261646d696e223b733a31393a2269734a617661736372697074456e61626c6564223b693a303b733a31313a22656d7074796c61796f7574223b733a31373a2261646d696e2f656d7074796c61796f7574223b733a363a226c61796f7574223b733a31323a2261646d696e2f6c61796f7574223b733a373a226661696c757265223b4e3b733a373a2273756363657373223b4e3b733a31353a2270617373776f726445787069726564223b733a313a2232223b733a383a226c6f67676564496e223b693a313b733a383a227573657274797065223b733a303a22223b733a343a22726f6c65223b733a31303a22537570657261646d696e223b733a383a22757365726e616d65223b733a31343a22537570657241646d696e2b474747223b733a31303a2275736572747970656964223b4e3b733a363a22726f6c656964223b733a313a2235223b733a363a22757365726964223b733a323a223634223b733a393a2275736572656d61696c223b733a32323a22737570657261646d696e253430676d61696c2e636f6d223b733a383a227072696f72697479223b733a313a2231223b733a31313a22757365726c6f67696e6964223b733a32303a22737570657261646d696e40676d61696c2e636f6d223b733a31303a2266697273746c6f67696e223b733a313a2230223b733a31353a227365637572697479656e61626c6564223b733a313a2231223b733a32313a22726573657470617373776f72647265717569726564223b693a313b7d6164646d65726368616e747c613a313a7b733a373a2273756363657373223b4e3b7d, 1365965366, '2013-04-13 23:08:49', NULL, '2013-04-14 18:39:27', NULL, NULL),
('ct8lvff1srt49ep19o2tmqufe7', 'd18e6bdfae14d5729064b3312d223e11', 0x6164646d65726368616e747c613a313a7b733a373a2273756363657373223b4e3b7d4d79506f7274616c7c613a363a7b733a333a22617070223b733a353a2261646d696e223b733a31393a2269734a617661736372697074456e61626c6564223b693a303b733a31313a22656d7074796c61796f7574223b733a31373a2261646d696e2f656d7074796c61796f7574223b733a363a226c61796f7574223b733a31323a2261646d696e2f6c61796f7574223b733a373a226661696c757265223b4e3b733a373a2273756363657373223b4e3b7d, 1366657981, '2013-04-22 20:34:49', NULL, '2013-04-22 18:14:02', NULL, NULL),
('ctqlj1ps2bv85hb2n0hjpklsr0', '3cf4c23e4201565642bf5b496a65f13e', 0x4d79506f7274616c7c613a373a7b733a333a22617070223b733a353a2261646d696e223b733a31393a2269734a617661736372697074456e61626c6564223b693a303b733a31313a22656d7074796c61796f7574223b733a31373a2261646d696e2f656d7074796c61796f7574223b733a363a226c61796f7574223b733a31323a2261646d696e2f6c61796f7574223b733a373a226661696c757265223b4e3b733a373a2273756363657373223b4e3b733a383a226c6f67676564496e223b4e3b7d6164646d65726368616e747c613a313a7b733a373a2273756363657373223b4e3b7d, 1365157356, '2013-04-05 15:49:35', NULL, '2013-04-05 10:19:37', NULL, NULL),
('d2mstvqusp060c4o65ref7op64', '3cf4c23e4201565642bf5b496a65f13e', 0x6164646d65726368616e747c613a313a7b733a373a2273756363657373223b4e3b7d4d79506f7274616c7c613a363a7b733a333a22617070223b733a353a2261646d696e223b733a31393a2269734a617661736372697074456e61626c6564223b693a303b733a31313a22656d7074796c61796f7574223b733a31373a2261646d696e2f656d7074796c61796f7574223b733a363a226c61796f7574223b733a31323a2261646d696e2f6c61796f7574223b733a373a226661696c757265223b4e3b733a373a2273756363657373223b4e3b7d, 1365360164, '2013-04-07 22:22:24', NULL, '2013-04-07 18:39:45', NULL, NULL),
('d9bb3jqg686195biiubf31prc3', '3cf4c23e4201565642bf5b496a65f13e', 0x6164646d65726368616e747c613a313a7b733a373a2273756363657373223b733a303a22223b7d4d79506f7274616c7c613a32303a7b733a333a22617070223b733a353a2261646d696e223b733a31393a2269734a617661736372697074456e61626c6564223b693a303b733a31313a22656d7074796c61796f7574223b733a31373a2261646d696e2f656d7074796c61796f7574223b733a363a226c61796f7574223b733a31323a2261646d696e2f6c61796f7574223b733a373a226661696c757265223b4e3b733a373a2273756363657373223b4e3b733a31353a2270617373776f726445787069726564223b733a313a2232223b733a383a226c6f67676564496e223b693a313b733a383a227573657274797065223b733a303a22223b733a343a22726f6c65223b733a31303a22537570657261646d696e223b733a383a22757365726e616d65223b733a31343a22537570657241646d696e2b474747223b733a31303a2275736572747970656964223b4e3b733a363a22726f6c656964223b733a313a2235223b733a363a22757365726964223b733a323a223634223b733a393a2275736572656d61696c223b733a32323a22737570657261646d696e253430676d61696c2e636f6d223b733a383a227072696f72697479223b733a313a2231223b733a31313a22757365726c6f67696e6964223b733a32303a22737570657261646d696e40676d61696c2e636f6d223b733a31303a2266697273746c6f67696e223b733a313a2230223b733a31353a227365637572697479656e61626c6564223b733a313a2231223b733a32313a22726573657470617373776f72647265717569726564223b693a303b7d, 1365449905, '2013-04-08 19:46:44', NULL, '2013-04-08 19:28:26', NULL, NULL),
('db8dpdd6cd36v4qrs6r013ggr1', '3cf4c23e4201565642bf5b496a65f13e', 0x4d79506f7274616c7c613a32313a7b733a383a226c6f67676564496e223b693a313b733a333a22617070223b733a353a2261646d696e223b733a31303a2266697273746c6f67696e223b733a313a2231223b733a31353a227365637572697479656e61626c6564223b733a313a2231223b733a31393a2269734a617661736372697074456e61626c6564223b693a303b733a31313a22656d7074796c61796f7574223b733a31373a2261646d696e2f656d7074796c61796f7574223b733a363a226c61796f7574223b733a31323a2261646d696e2f6c61796f7574223b733a373a226661696c757265223b4e3b733a373a2273756363657373223b4e3b733a31353a2270617373776f726445787069726564223b733a313a2232223b733a383a227573657274797065223b733a303a22223b733a343a22726f6c65223b733a31303a22537570657261646d696e223b733a383a22757365726e616d65223b733a393a2268656d612b76617375223b733a31303a2275736572747970656964223b4e3b733a363a22726f6c656964223b733a313a2235223b733a363a22757365726964223b733a323a223634223b733a393a2275736572656d61696c223b733a32303a227661737568656d612534307961686f6f2e636f6d223b733a383a227072696f72697479223b733a313a2231223b733a31313a22757365726c6f67696e6964223b733a31383a227661737568656d61407961686f6f2e636f6d223b733a32313a22726573657470617373776f72647265717569726564223b693a313b733a31333a2276616c69646174656572726f72223b4e3b7d6164646d65726368616e747c613a313a7b733a373a2273756363657373223b4e3b7d, 1365082888, '2013-04-04 18:35:25', NULL, '2013-04-04 13:38:29', NULL, NULL),
('drc6n7rqsdh045p37jvh0e4fi6', '5c8a8ffed19567e500dc1d7127309813', 0x4d79506f7274616c7c613a363a7b733a333a22617070223b733a353a2261646d696e223b733a31393a2269734a617661736372697074456e61626c6564223b693a303b733a31313a22656d7074796c61796f7574223b733a31373a2261646d696e2f656d7074796c61796f7574223b733a363a226c61796f7574223b733a31323a2261646d696e2f6c61796f7574223b733a373a226661696c757265223b4e3b733a373a2273756363657373223b4e3b7d6164646d65726368616e747c613a313a7b733a373a2273756363657373223b4e3b7d, 1365875304, '2013-04-13 23:08:01', NULL, '2013-04-13 17:38:25', NULL, NULL),
('ek231ij7e9rgr53igc9kr9ldp0', 'd18e6bdfae14d5729064b3312d223e11', 0x4d79506f7274616c7c613a32303a7b733a333a22617070223b733a353a2261646d696e223b733a31303a2266697273746c6f67696e223b733a313a2230223b733a31353a227365637572697479656e61626c6564223b733a313a2231223b733a383a226c6f67676564496e223b693a313b733a31393a2269734a617661736372697074456e61626c6564223b693a303b733a31313a22656d7074796c61796f7574223b733a31373a2261646d696e2f656d7074796c61796f7574223b733a363a226c61796f7574223b733a31323a2261646d696e2f6c61796f7574223b733a373a226661696c757265223b4e3b733a373a2273756363657373223b4e3b733a31353a2270617373776f726445787069726564223b733a313a2232223b733a383a227573657274797065223b733a303a22223b733a343a22726f6c65223b733a31303a22537570657261646d696e223b733a383a22757365726e616d65223b733a31343a22537570657241646d696e2b474747223b733a31303a2275736572747970656964223b4e3b733a363a22726f6c656964223b733a313a2235223b733a363a22757365726964223b733a323a223634223b733a393a2275736572656d61696c223b733a32323a22737570657261646d696e253430676d61696c2e636f6d223b733a383a227072696f72697479223b733a313a2231223b733a31313a22757365726c6f67696e6964223b733a32303a22737570657261646d696e40676d61696c2e636f6d223b733a32313a22726573657470617373776f72647265717569726564223b693a313b7d6164646d65726368616e747c613a313a7b733a373a2273756363657373223b4e3b7d, 1367475757, '2013-05-02 10:52:29', NULL, '2013-05-02 05:23:38', NULL, NULL),
('g9j0l2nps5kpi20eetncsbp9t0', '5c8a8ffed19567e500dc1d7127309813', 0x4d79506f7274616c7c613a32313a7b733a333a22617070223b733a353a2261646d696e223b733a31303a2266697273746c6f67696e223b733a313a2230223b733a31353a227365637572697479656e61626c6564223b733a313a2231223b733a383a226c6f67676564496e223b693a313b733a31393a2269734a617661736372697074456e61626c6564223b693a303b733a31313a22656d7074796c61796f7574223b733a31373a2261646d696e2f656d7074796c61796f7574223b733a363a226c61796f7574223b733a31323a2261646d696e2f6c61796f7574223b733a373a226661696c757265223b4e3b733a373a2273756363657373223b733a303a22223b733a31353a2270617373776f726445787069726564223b733a313a2232223b733a383a227573657274797065223b733a303a22223b733a343a22726f6c65223b733a31303a22537570657261646d696e223b733a383a22757365726e616d65223b733a31343a22537570657241646d696e2b474747223b733a31303a2275736572747970656964223b4e3b733a363a22726f6c656964223b733a313a2235223b733a363a22757365726964223b733a323a223634223b733a393a2275736572656d61696c223b733a32323a22737570657261646d696e253430676d61696c2e636f6d223b733a383a227072696f72697479223b733a313a2231223b733a31313a22757365726c6f67696e6964223b733a32303a22737570657261646d696e40676d61696c2e636f6d223b733a32313a22726573657470617373776f72647265717569726564223b693a313b733a31333a2276616c69646174656572726f72223b733a303a22223b7d6164646d65726368616e747c613a313a7b733a373a2273756363657373223b4e3b7d, 1367147516, '2013-04-28 09:33:42', NULL, '2013-04-28 10:12:57', NULL, NULL),
('hdtpelkb585puh29all1b736a0', 'c71eea6252610d1d9ad594ae53982b74', 0x4d79506f7274616c7c613a32313a7b733a333a22617070223b733a353a2261646d696e223b733a383a226c6f67676564496e223b693a313b733a383a227573657274797065223b733a303a22223b733a343a22726f6c65223b733a31303a22537570657261646d696e223b733a383a22757365726e616d65223b733a31343a22537570657261646d696e2b4f6e65223b733a31303a2275736572747970656964223b4e3b733a363a22726f6c656964223b733a313a2235223b733a363a22757365726964223b733a323a223833223b733a393a2275736572656d61696c223b733a32323a22737570657261646d696e253430676d61696c2e636f6d223b733a383a227072696f72697479223b733a313a2231223b733a31313a22757365726c6f67696e6964223b733a32303a22737570657261646d696e40676d61696c2e636f6d223b733a31303a2266697273746c6f67696e223b733a313a2230223b733a31353a227365637572697479656e61626c6564223b733a313a2231223b733a31393a2269734a617661736372697074456e61626c6564223b693a303b733a31313a22656d7074796c61796f7574223b733a31373a2261646d696e2f656d7074796c61796f7574223b733a363a226c61796f7574223b733a31323a2261646d696e2f6c61796f7574223b733a373a226661696c757265223b4e3b733a373a2273756363657373223b733a303a22223b733a31353a2270617373776f726445787069726564223b733a313a2232223b733a32313a22726573657470617373776f72647265717569726564223b693a313b733a31333a2276616c69646174656572726f72223b4e3b7d6164646d65726368616e747c613a313a7b733a373a2273756363657373223b4e3b7d, 1370719275, '2013-06-08 08:15:16', NULL, '2013-06-08 18:22:16', NULL, NULL),
('i65sq2miav84t8c8j2tdbntn71', '5c8a8ffed19567e500dc1d7127309813', 0x4d79506f7274616c7c613a32313a7b733a333a22617070223b733a353a2261646d696e223b733a31393a2269734a617661736372697074456e61626c6564223b693a303b733a31313a22656d7074796c61796f7574223b733a31373a2261646d696e2f656d7074796c61796f7574223b733a363a226c61796f7574223b733a31323a2261646d696e2f6c61796f7574223b733a373a226661696c757265223b4e3b733a373a2273756363657373223b733a303a22223b733a31353a2270617373776f726445787069726564223b733a313a2232223b733a383a226c6f67676564496e223b693a313b733a383a227573657274797065223b733a303a22223b733a343a22726f6c65223b733a31303a22537570657261646d696e223b733a383a22757365726e616d65223b733a31343a22537570657241646d696e2b474747223b733a31303a2275736572747970656964223b4e3b733a363a22726f6c656964223b733a313a2235223b733a363a22757365726964223b733a323a223634223b733a393a2275736572656d61696c223b733a32323a22737570657261646d696e253430676d61696c2e636f6d223b733a383a227072696f72697479223b733a313a2231223b733a31313a22757365726c6f67696e6964223b733a32303a22737570657261646d696e40676d61696c2e636f6d223b733a31303a2266697273746c6f67696e223b733a313a2230223b733a31353a227365637572697479656e61626c6564223b733a313a2231223b733a32313a22726573657470617373776f72647265717569726564223b693a313b733a31333a2276616c69646174656572726f72223b733a303a22223b7d6164646d65726368616e747c613a313a7b733a373a2273756363657373223b4e3b7d, 1366571929, '2013-04-21 21:07:15', NULL, '2013-04-21 18:19:50', NULL, NULL),
('ia5bg2aeapaa0trda6snkiuv62', 'df3025e157f07d8defd08d0fb7c5843f', 0x4d79506f7274616c7c613a363a7b733a333a22617070223b733a353a2261646d696e223b733a31393a2269734a617661736372697074456e61626c6564223b693a303b733a31313a22656d7074796c61796f7574223b733a31373a2261646d696e2f656d7074796c61796f7574223b733a363a226c61796f7574223b733a31323a2261646d696e2f6c61796f7574223b733a373a226661696c757265223b4e3b733a373a2273756363657373223b4e3b7d6164646d65726368616e747c613a313a7b733a373a2273756363657373223b4e3b7d, 1366046784, '2013-04-15 20:27:08', NULL, '2013-04-15 17:16:25', NULL, NULL),
('it1ip52tntkq73tc4vmhuq4ju4', '5c8a8ffed19567e500dc1d7127309813', 0x4d79506f7274616c7c613a32313a7b733a333a22617070223b733a353a2261646d696e223b733a31393a2269734a617661736372697074456e61626c6564223b693a303b733a31313a22656d7074796c61796f7574223b733a31373a2261646d696e2f656d7074796c61796f7574223b733a363a226c61796f7574223b733a31323a2261646d696e2f6c61796f7574223b733a373a226661696c757265223b4e3b733a373a2273756363657373223b4e3b733a31353a2270617373776f726445787069726564223b733a313a2232223b733a383a226c6f67676564496e223b693a313b733a383a227573657274797065223b733a303a22223b733a343a22726f6c65223b733a31303a22537570657261646d696e223b733a383a22757365726e616d65223b733a31343a22537570657241646d696e2b474747223b733a31303a2275736572747970656964223b4e3b733a363a22726f6c656964223b733a313a2235223b733a363a22757365726964223b733a323a223634223b733a393a2275736572656d61696c223b733a32323a22737570657261646d696e253430676d61696c2e636f6d223b733a383a227072696f72697479223b733a313a2231223b733a31313a22757365726c6f67696e6964223b733a32303a22737570657261646d696e40676d61696c2e636f6d223b733a31303a2266697273746c6f67696e223b733a313a2230223b733a31353a227365637572697479656e61626c6564223b733a313a2231223b733a32313a22726573657470617373776f72647265717569726564223b693a313b733a31333a2276616c69646174656572726f72223b4e3b7d6164646d65726368616e747c613a313a7b733a373a2273756363657373223b4e3b7d, 1367168841, '2013-04-28 19:29:58', NULL, '2013-04-28 16:08:22', NULL, NULL),
('j4ea3agetnvsovmomok98oi9g3', 'd18e6bdfae14d5729064b3312d223e11', 0x6164646d65726368616e747c613a313a7b733a373a2273756363657373223b4e3b7d4d79506f7274616c7c613a32313a7b733a333a22617070223b733a353a2261646d696e223b733a31393a2269734a617661736372697074456e61626c6564223b693a303b733a31313a22656d7074796c61796f7574223b733a31373a2261646d696e2f656d7074796c61796f7574223b733a363a226c61796f7574223b733a31323a2261646d696e2f6c61796f7574223b733a373a226661696c757265223b4e3b733a373a2273756363657373223b4e3b733a31353a2270617373776f726445787069726564223b733a313a2232223b733a383a226c6f67676564496e223b693a313b733a383a227573657274797065223b733a303a22223b733a343a22726f6c65223b733a31303a22537570657261646d696e223b733a383a22757365726e616d65223b733a31343a22537570657241646d696e2b474747223b733a31303a2275736572747970656964223b4e3b733a363a22726f6c656964223b733a313a2235223b733a363a22757365726964223b733a323a223634223b733a393a2275736572656d61696c223b733a32323a22737570657261646d696e253430676d61696c2e636f6d223b733a383a227072696f72697479223b733a313a2231223b733a31313a22757365726c6f67696e6964223b733a32303a22737570657261646d696e40676d61696c2e636f6d223b733a31303a2266697273746c6f67696e223b733a313a2230223b733a31353a227365637572697479656e61626c6564223b733a313a2231223b733a32313a22726573657470617373776f72647265717569726564223b693a313b733a31333a2276616c69646174656572726f72223b4e3b7d, 1367330253, '2013-04-30 09:52:31', NULL, '2013-04-30 12:58:34', NULL, NULL),
('k0v6efsp676e6sbjampqqj1iq5', 'd18e6bdfae14d5729064b3312d223e11', 0x4d79506f7274616c7c613a32313a7b733a333a22617070223b733a353a2261646d696e223b733a31303a2266697273746c6f67696e223b733a313a2230223b733a31353a227365637572697479656e61626c6564223b733a313a2231223b733a383a226c6f67676564496e223b693a313b733a31393a2269734a617661736372697074456e61626c6564223b693a303b733a31313a22656d7074796c61796f7574223b733a31373a2261646d696e2f656d7074796c61796f7574223b733a363a226c61796f7574223b733a31323a2261646d696e2f6c61796f7574223b733a373a226661696c757265223b4e3b733a373a2273756363657373223b4e3b733a31353a2270617373776f726445787069726564223b733a313a2232223b733a383a227573657274797065223b733a303a22223b733a343a22726f6c65223b733a31303a22537570657261646d696e223b733a383a22757365726e616d65223b733a31343a22537570657241646d696e2b474747223b733a31303a2275736572747970656964223b4e3b733a363a22726f6c656964223b733a313a2235223b733a363a22757365726964223b733a323a223634223b733a393a2275736572656d61696c223b733a32323a22737570657261646d696e253430676d61696c2e636f6d223b733a383a227072696f72697479223b733a313a2231223b733a31313a22757365726c6f67696e6964223b733a32303a22737570657261646d696e40676d61696c2e636f6d223b733a32313a22726573657470617373776f72647265717569726564223b693a313b733a31333a2276616c69646174656572726f72223b4e3b7d6164646d65726368616e747c613a313a7b733a373a2273756363657373223b4e3b7d, 1366897266, '2013-04-25 10:16:03', NULL, '2013-04-25 12:42:07', NULL, NULL),
('k47eomihqt1j7sofh59gls6922', '3cf4c23e4201565642bf5b496a65f13e', 0x4d79506f7274616c7c613a32313a7b733a333a22617070223b733a353a2261646d696e223b733a31393a2269734a617661736372697074456e61626c6564223b693a303b733a31313a22656d7074796c61796f7574223b733a31373a2261646d696e2f656d7074796c61796f7574223b733a363a226c61796f7574223b733a31323a2261646d696e2f6c61796f7574223b733a373a226661696c757265223b4e3b733a373a2273756363657373223b4e3b733a383a226c6f67676564496e223b693a313b733a31353a2270617373776f726445787069726564223b733a313a2232223b733a383a227573657274797065223b733a303a22223b733a343a22726f6c65223b733a31303a22537570657261646d696e223b733a383a22757365726e616d65223b733a31323a22537570657241646d696e2b47223b733a31303a2275736572747970656964223b4e3b733a363a22726f6c656964223b733a313a2235223b733a363a22757365726964223b733a323a223634223b733a393a2275736572656d61696c223b733a32323a22737570657261646d696e253430676d61696c2e636f6d223b733a383a227072696f72697479223b733a313a2231223b733a31313a22757365726c6f67696e6964223b733a32303a22737570657261646d696e40676d61696c2e636f6d223b733a31303a2266697273746c6f67696e223b733a313a2231223b733a31353a227365637572697479656e61626c6564223b733a313a2231223b733a32313a22726573657470617373776f72647265717569726564223b693a303b733a31333a2276616c69646174656572726f72223b4e3b7d6164646d65726368616e747c613a313a7b733a373a2273756363657373223b4e3b7d, 1365246986, '2013-04-06 12:12:57', NULL, '2013-04-06 11:13:27', NULL, NULL),
('kj19od92i6e16jdpjaa0a5udp7', 'df3025e157f07d8defd08d0fb7c5843f', '', 1366441957, '2013-04-20 10:49:34', NULL, '2013-04-20 07:02:38', NULL, NULL),
('klr3biancfdd0eceg1tvtnnrl6', 'd18e6bdfae14d5729064b3312d223e11', '', 1368104624, '2013-05-09 11:54:50', NULL, '2013-05-09 12:04:45', NULL, NULL),
('l6kahg4h387gpc8eu9o3dia6u5', 'df3025e157f07d8defd08d0fb7c5843f', 0x6164646d65726368616e747c613a313a7b733a373a2273756363657373223b4e3b7d4d79506f7274616c7c613a32303a7b733a333a22617070223b733a353a2261646d696e223b733a31393a2269734a617661736372697074456e61626c6564223b693a303b733a31313a22656d7074796c61796f7574223b733a31373a2261646d696e2f656d7074796c61796f7574223b733a363a226c61796f7574223b733a31323a2261646d696e2f6c61796f7574223b733a373a226661696c757265223b4e3b733a373a2273756363657373223b4e3b733a31353a2270617373776f726445787069726564223b733a313a2232223b733a383a226c6f67676564496e223b693a313b733a383a227573657274797065223b733a303a22223b733a343a22726f6c65223b733a31303a22537570657261646d696e223b733a383a22757365726e616d65223b733a31343a22537570657241646d696e2b474747223b733a31303a2275736572747970656964223b4e3b733a363a22726f6c656964223b733a313a2235223b733a363a22757365726964223b733a323a223634223b733a393a2275736572656d61696c223b733a32323a22737570657261646d696e253430676d61696c2e636f6d223b733a383a227072696f72697479223b733a313a2231223b733a31313a22757365726c6f67696e6964223b733a32303a22737570657261646d696e40676d61696c2e636f6d223b733a31303a2266697273746c6f67696e223b733a313a2230223b733a31353a227365637572697479656e61626c6564223b733a313a2231223b733a32313a22726573657470617373776f72647265717569726564223b693a313b7d, 1365965126, '2013-04-14 17:34:51', NULL, '2013-04-14 18:35:27', NULL, NULL),
('mb8qqvbuupq3frnl9pr31nd846', '3cf4c23e4201565642bf5b496a65f13e', 0x4d79506f7274616c7c613a363a7b733a333a22617070223b733a353a2261646d696e223b733a31393a2269734a617661736372697074456e61626c6564223b693a303b733a31313a22656d7074796c61796f7574223b733a31373a2261646d696e2f656d7074796c61796f7574223b733a363a226c61796f7574223b733a31323a2261646d696e2f6c61796f7574223b733a373a226661696c757265223b4e3b733a373a2273756363657373223b4e3b7d6164646d65726368616e747c613a313a7b733a373a2273756363657373223b4e3b7d, 1365353530, '2013-04-07 22:16:43', NULL, '2013-04-07 16:49:11', NULL, NULL),
('n3e24oghj2l4ag92tn27i4cja1', 'a5f724d1b119d6198c6e59fe73fc0807', 0x4d79506f7274616c7c613a32313a7b733a333a22617070223b733a353a2261646d696e223b733a31303a2266697273746c6f67696e223b733a313a2230223b733a31353a227365637572697479656e61626c6564223b733a313a2231223b733a383a226c6f67676564496e223b693a313b733a31393a2269734a617661736372697074456e61626c6564223b693a303b733a31313a22656d7074796c61796f7574223b733a31373a2261646d696e2f656d7074796c61796f7574223b733a363a226c61796f7574223b733a31323a2261646d696e2f6c61796f7574223b733a373a226661696c757265223b4e3b733a373a2273756363657373223b4e3b733a31353a2270617373776f726445787069726564223b733a313a2232223b733a383a227573657274797065223b733a303a22223b733a343a22726f6c65223b733a31303a22537570657261646d696e223b733a383a22757365726e616d65223b733a31333a22537570657241646d696e2b4747223b733a31303a2275736572747970656964223b4e3b733a363a22726f6c656964223b733a313a2235223b733a363a22757365726964223b733a323a223634223b733a393a2275736572656d61696c223b733a32323a22737570657261646d696e253430676d61696c2e636f6d223b733a383a227072696f72697479223b733a313a2231223b733a31313a22757365726c6f67696e6964223b733a32303a22737570657261646d696e40676d61696c2e636f6d223b733a32313a22726573657470617373776f72647265717569726564223b693a303b733a31333a2276616c69646174656572726f72223b4e3b7d6164646d65726368616e747c613a313a7b733a373a2273756363657373223b4e3b7d, 1365352789, '2013-04-07 21:56:08', NULL, '2013-04-07 16:36:50', NULL, NULL),
('ngvgqt8k2cs3mkvrd9kv8ud235', 'd18e6bdfae14d5729064b3312d223e11', 0x4d79506f7274616c7c613a32313a7b733a333a22617070223b733a353a2261646d696e223b733a31303a2266697273746c6f67696e223b733a313a2230223b733a31353a227365637572697479656e61626c6564223b733a313a2231223b733a383a226c6f67676564496e223b693a313b733a31393a2269734a617661736372697074456e61626c6564223b693a303b733a31313a22656d7074796c61796f7574223b733a31373a2261646d696e2f656d7074796c61796f7574223b733a363a226c61796f7574223b733a31323a2261646d696e2f6c61796f7574223b733a373a226661696c757265223b4e3b733a373a2273756363657373223b4e3b733a31353a2270617373776f726445787069726564223b733a313a2232223b733a383a227573657274797065223b733a303a22223b733a343a22726f6c65223b733a31303a22537570657261646d696e223b733a383a22757365726e616d65223b733a31343a22537570657241646d696e2b474747223b733a31303a2275736572747970656964223b4e3b733a363a22726f6c656964223b733a313a2235223b733a363a22757365726964223b733a323a223634223b733a393a2275736572656d61696c223b733a32323a22737570657261646d696e253430676d61696c2e636f6d223b733a383a227072696f72697479223b733a313a2231223b733a31313a22757365726c6f67696e6964223b733a32303a22737570657261646d696e40676d61696c2e636f6d223b733a32313a22726573657470617373776f72647265717569726564223b693a313b733a31333a2276616c69646174656572726f72223b4e3b7d6164646d65726368616e747c613a313a7b733a373a2273756363657373223b4e3b7d, 1367414481, '2013-05-01 09:55:45', NULL, '2013-05-01 12:22:22', NULL, NULL),
('o3g267qghh6dpinv3dqga7lsu0', '34b4bebc862c31642714199c925cabcc', 0x6164646d65726368616e747c613a313a7b733a373a2273756363657373223b733a303a22223b7d4d79506f7274616c7c613a363a7b733a333a22617070223b733a353a2261646d696e223b733a31393a2269734a617661736372697074456e61626c6564223b693a303b733a31313a22656d7074796c61796f7574223b733a31373a2261646d696e2f656d7074796c61796f7574223b733a363a226c61796f7574223b733a31323a2261646d696e2f6c61796f7574223b733a373a226661696c757265223b4e3b733a373a2273756363657373223b4e3b7d, 1370173527, '2013-06-02 13:44:39', NULL, '2013-06-02 10:46:28', NULL, NULL);
INSERT INTO `apmsessiondata` (`sessid`, `sesshttpuseragent`, `sessdata`, `sessexpire`, `createddatetime`, `deleteddatetime`, `updateddatetime`, `createdby`, `lastupdatedby`) VALUES
('o5gtir0ff2psen7jfjoipggqb3', 'd18e6bdfae14d5729064b3312d223e11', 0x4d79506f7274616c7c613a32313a7b733a333a22617070223b733a353a2261646d696e223b733a31303a2266697273746c6f67696e223b733a313a2230223b733a31353a227365637572697479656e61626c6564223b733a313a2231223b733a383a226c6f67676564496e223b693a313b733a31393a2269734a617661736372697074456e61626c6564223b693a303b733a31313a22656d7074796c61796f7574223b733a31373a2261646d696e2f656d7074796c61796f7574223b733a363a226c61796f7574223b733a31323a2261646d696e2f6c61796f7574223b733a373a226661696c757265223b4e3b733a373a2273756363657373223b733a34363a2263617465676f7279203330202064657461696c7320776572652075706461746564207375636365737366756c6c79223b733a31353a2270617373776f726445787069726564223b733a313a2232223b733a383a227573657274797065223b733a303a22223b733a343a22726f6c65223b733a31303a22537570657261646d696e223b733a383a22757365726e616d65223b733a31343a22537570657241646d696e2b474747223b733a31303a2275736572747970656964223b4e3b733a363a22726f6c656964223b733a313a2235223b733a363a22757365726964223b733a323a223634223b733a393a2275736572656d61696c223b733a32323a22737570657261646d696e253430676d61696c2e636f6d223b733a383a227072696f72697479223b733a313a2231223b733a31313a22757365726c6f67696e6964223b733a32303a22737570657261646d696e40676d61696c2e636f6d223b733a32313a22726573657470617373776f72647265717569726564223b693a313b733a31333a2276616c69646174656572726f72223b733a303a22223b7d6164646d65726368616e747c613a313a7b733a373a2273756363657373223b4e3b7d, 1366719627, '2013-04-23 11:33:09', NULL, '2013-04-23 11:21:28', NULL, NULL),
('ocr010ces2b5chkldh7nldklj7', 'c71eea6252610d1d9ad594ae53982b74', 0x4d79506f7274616c7c613a32313a7b733a333a22617070223b733a353a2261646d696e223b733a31393a2269734a617661736372697074456e61626c6564223b693a303b733a31313a22656d7074796c61796f7574223b733a31373a2261646d696e2f656d7074796c61796f7574223b733a363a226c61796f7574223b733a31323a2261646d696e2f6c61796f7574223b733a373a226661696c757265223b4e3b733a373a2273756363657373223b733a303a22223b733a31353a2270617373776f726445787069726564223b733a313a2232223b733a383a226c6f67676564496e223b693a313b733a383a227573657274797065223b733a303a22223b733a343a22726f6c65223b733a31303a22537570657261646d696e223b733a383a22757365726e616d65223b733a31343a22537570657261646d696e2b4f6e65223b733a31303a2275736572747970656964223b4e3b733a363a22726f6c656964223b733a313a2235223b733a363a22757365726964223b733a323a223833223b733a393a2275736572656d61696c223b733a32323a22737570657261646d696e253430676d61696c2e636f6d223b733a383a227072696f72697479223b733a313a2231223b733a31313a22757365726c6f67696e6964223b733a32303a22737570657261646d696e40676d61696c2e636f6d223b733a31303a2266697273746c6f67696e223b733a313a2230223b733a31353a227365637572697479656e61626c6564223b733a313a2231223b733a32313a22726573657470617373776f72647265717569726564223b693a313b733a31333a2276616c69646174656572726f72223b4e3b7d6164646d65726368616e747c613a313a7b733a373a2273756363657373223b4e3b7d, 1370542260, '2013-06-06 22:13:08', NULL, '2013-06-06 17:12:01', NULL, NULL),
('ogpvin3g1fn5kl7m5aqn1tu3a3', 'd18e6bdfae14d5729064b3312d223e11', 0x4d79506f7274616c7c613a32313a7b733a333a22617070223b733a353a2261646d696e223b733a31303a2266697273746c6f67696e223b733a313a2230223b733a31353a227365637572697479656e61626c6564223b733a313a2231223b733a383a226c6f67676564496e223b693a313b733a31393a2269734a617661736372697074456e61626c6564223b693a303b733a31313a22656d7074796c61796f7574223b733a31373a2261646d696e2f656d7074796c61796f7574223b733a363a226c61796f7574223b733a31323a2261646d696e2f6c61796f7574223b733a373a226661696c757265223b4e3b733a373a2273756363657373223b4e3b733a31353a2270617373776f726445787069726564223b733a313a2232223b733a383a227573657274797065223b733a303a22223b733a343a22726f6c65223b733a31303a22537570657261646d696e223b733a383a22757365726e616d65223b733a31343a22537570657241646d696e2b474747223b733a31303a2275736572747970656964223b4e3b733a363a22726f6c656964223b733a313a2235223b733a363a22757365726964223b733a323a223634223b733a393a2275736572656d61696c223b733a32323a22737570657261646d696e253430676d61696c2e636f6d223b733a383a227072696f72697479223b733a313a2231223b733a31313a22757365726c6f67696e6964223b733a32303a22737570657261646d696e40676d61696c2e636f6d223b733a32313a22726573657470617373776f72647265717569726564223b693a313b733a31333a2276616c69646174656572726f72223b4e3b7d6164646d65726368616e747c613a313a7b733a373a2273756363657373223b4e3b7d, 1366465035, '2013-04-20 11:51:35', NULL, '2013-04-20 12:38:16', NULL, NULL),
('oo87cnsnpkaus0honfh8fvqbk0', '34b4bebc862c31642714199c925cabcc', 0x4d79506f7274616c7c613a32303a7b733a333a22617070223b733a353a2261646d696e223b733a31393a2269734a617661736372697074456e61626c6564223b693a303b733a31313a22656d7074796c61796f7574223b733a31373a2261646d696e2f656d7074796c61796f7574223b733a363a226c61796f7574223b733a31323a2261646d696e2f6c61796f7574223b733a373a226661696c757265223b4e3b733a373a2273756363657373223b4e3b733a31353a2270617373776f726445787069726564223b733a313a2232223b733a383a226c6f67676564496e223b693a313b733a383a227573657274797065223b733a303a22223b733a343a22726f6c65223b4e3b733a383a22757365726e616d65223b733a303a22223b733a31303a2275736572747970656964223b4e3b733a363a22726f6c656964223b4e3b733a363a22757365726964223b4e3b733a393a2275736572656d61696c223b733a303a22223b733a383a227072696f72697479223b4e3b733a31313a22757365726c6f67696e6964223b4e3b733a31303a2266697273746c6f67696e223b4e3b733a31353a227365637572697479656e61626c6564223b4e3b733a32313a22726573657470617373776f72647265717569726564223b693a313b7d6164646d65726368616e747c613a313a7b733a373a2273756363657373223b4e3b7d, 1370158226, '2013-06-02 11:58:43', NULL, '2013-06-02 06:31:27', NULL, NULL),
('phi4kmve93dk6kp4l20leea000', 'a5f724d1b119d6198c6e59fe73fc0807', 0x4d79506f7274616c7c613a373a7b733a333a22617070223b733a353a2261646d696e223b733a31393a2269734a617661736372697074456e61626c6564223b693a303b733a31313a22656d7074796c61796f7574223b733a31373a2261646d696e2f656d7074796c61796f7574223b733a363a226c61796f7574223b733a31323a2261646d696e2f6c61796f7574223b733a373a226661696c757265223b4e3b733a373a2273756363657373223b4e3b733a383a226c6f67676564496e223b4e3b7d6164646d65726368616e747c613a313a7b733a373a2273756363657373223b4e3b7d, 1365267413, '2013-04-06 21:39:56', NULL, '2013-04-06 16:53:54', NULL, NULL),
('pp9dt3l8urnvfk0bm9fbc5ipe0', 'df3025e157f07d8defd08d0fb7c5843f', 0x4d79506f7274616c7c613a32313a7b733a333a22617070223b733a353a2261646d696e223b733a31393a2269734a617661736372697074456e61626c6564223b693a303b733a31313a22656d7074796c61796f7574223b733a31373a2261646d696e2f656d7074796c61796f7574223b733a363a226c61796f7574223b733a31323a2261646d696e2f6c61796f7574223b733a373a226661696c757265223b4e3b733a373a2273756363657373223b4e3b733a383a226c6f67676564496e223b693a313b733a31353a2270617373776f726445787069726564223b733a313a2232223b733a383a227573657274797065223b733a303a22223b733a343a22726f6c65223b733a31303a22537570657261646d696e223b733a383a22757365726e616d65223b733a393a2268656d612b76617375223b733a31303a2275736572747970656964223b4e3b733a363a22726f6c656964223b733a313a2235223b733a363a22757365726964223b733a323a223634223b733a393a2275736572656d61696c223b733a32303a227661737568656d612534307961686f6f2e636f6d223b733a383a227072696f72697479223b733a313a2231223b733a31313a22757365726c6f67696e6964223b733a31383a227661737568656d61407961686f6f2e636f6d223b733a31303a2266697273746c6f67696e223b733a313a2231223b733a31353a227365637572697479656e61626c6564223b733a313a2231223b733a32313a22726573657470617373776f72647265717569726564223b693a313b733a31333a2276616c69646174656572726f72223b4e3b7d6164646d65726368616e747c613a313a7b733a373a2273756363657373223b4e3b7d, 1365158815, '2013-04-05 10:59:21', NULL, '2013-04-05 10:43:56', NULL, NULL),
('q116itcac9et7jcjb5jpnslc52', 'd18e6bdfae14d5729064b3312d223e11', 0x4d79506f7274616c7c613a32313a7b733a333a22617070223b733a353a2261646d696e223b733a31393a2269734a617661736372697074456e61626c6564223b693a303b733a31313a22656d7074796c61796f7574223b733a31373a2261646d696e2f656d7074796c61796f7574223b733a363a226c61796f7574223b733a31323a2261646d696e2f6c61796f7574223b733a373a226661696c757265223b4e3b733a373a2273756363657373223b4e3b733a31353a2270617373776f726445787069726564223b733a313a2232223b733a383a226c6f67676564496e223b693a313b733a383a227573657274797065223b733a303a22223b733a343a22726f6c65223b733a31303a22537570657261646d696e223b733a383a22757365726e616d65223b733a31343a22537570657241646d696e2b474747223b733a31303a2275736572747970656964223b4e3b733a363a22726f6c656964223b733a313a2235223b733a363a22757365726964223b733a323a223634223b733a393a2275736572656d61696c223b733a32323a22737570657261646d696e253430676d61696c2e636f6d223b733a383a227072696f72697479223b733a313a2231223b733a31313a22757365726c6f67696e6964223b733a32303a22737570657261646d696e40676d61696c2e636f6d223b733a31303a2266697273746c6f67696e223b733a313a2230223b733a31353a227365637572697479656e61626c6564223b733a313a2231223b733a32313a22726573657470617373776f72647265717569726564223b693a313b733a31333a2276616c69646174656572726f72223b4e3b7d6164646d65726368616e747c613a313a7b733a373a2273756363657373223b4e3b7d, 1367349360, '2013-04-30 20:43:40', NULL, '2013-04-30 18:17:01', NULL, NULL),
('q503aj8ivr5eeek9e312ntmjm6', 'a5f724d1b119d6198c6e59fe73fc0807', 0x4d79506f7274616c7c613a343a7b733a333a22617070223b733a353a2261646d696e223b733a31393a2269734a617661736372697074456e61626c6564223b693a303b733a31313a22656d7074796c61796f7574223b733a31373a2261646d696e2f656d7074796c61796f7574223b733a363a226c61796f7574223b733a31323a2261646d696e2f6c61796f7574223b7d, 1365266956, '2013-04-06 22:16:17', NULL, '2013-04-06 16:46:17', NULL, NULL),
('q5ksvc14csb4aeigoccg31ktk7', '3cf4c23e4201565642bf5b496a65f13e', 0x4d79506f7274616c7c613a363a7b733a333a22617070223b733a353a2261646d696e223b733a31393a2269734a617661736372697074456e61626c6564223b693a303b733a31313a22656d7074796c61796f7574223b733a31373a2261646d696e2f656d7074796c61796f7574223b733a363a226c61796f7574223b733a31323a2261646d696e2f6c61796f7574223b733a373a226661696c757265223b4e3b733a373a2273756363657373223b4e3b7d6164646d65726368616e747c613a313a7b733a373a2273756363657373223b4e3b7d, 1365271419, '2013-04-06 23:28:07', NULL, '2013-04-06 18:00:40', NULL, NULL),
('qeamfv0l958vfdvdts73pcek06', '3cf4c23e4201565642bf5b496a65f13e', 0x4d79506f7274616c7c613a363a7b733a333a22617070223b733a353a2261646d696e223b733a31393a2269734a617661736372697074456e61626c6564223b693a303b733a31313a22656d7074796c61796f7574223b733a31373a2261646d696e2f656d7074796c61796f7574223b733a363a226c61796f7574223b733a31323a2261646d696e2f6c61796f7574223b733a373a226661696c757265223b4e3b733a373a2273756363657373223b4e3b7d6164646d65726368616e747c613a313a7b733a373a2273756363657373223b4e3b7d, 1365353703, '2013-04-07 22:19:24', NULL, '2013-04-07 16:52:04', NULL, NULL),
('r746psfs1vcg29a8anccva67c4', 'd18e6bdfae14d5729064b3312d223e11', 0x6164646d65726368616e747c613a313a7b733a373a2273756363657373223b4e3b7d4d79506f7274616c7c613a32303a7b733a333a22617070223b733a353a2261646d696e223b733a31393a2269734a617661736372697074456e61626c6564223b693a303b733a31313a22656d7074796c61796f7574223b733a31373a2261646d696e2f656d7074796c61796f7574223b733a363a226c61796f7574223b733a31323a2261646d696e2f6c61796f7574223b733a373a226661696c757265223b4e3b733a373a2273756363657373223b4e3b733a31353a2270617373776f726445787069726564223b733a313a2232223b733a383a226c6f67676564496e223b693a313b733a383a227573657274797065223b733a303a22223b733a343a22726f6c65223b733a31303a22537570657261646d696e223b733a383a22757365726e616d65223b733a31343a22537570657241646d696e2b474747223b733a31303a2275736572747970656964223b4e3b733a363a22726f6c656964223b733a313a2235223b733a363a22757365726964223b733a323a223634223b733a393a2275736572656d61696c223b733a32323a22737570657261646d696e253430676d61696c2e636f6d223b733a383a227072696f72697479223b733a313a2231223b733a31313a22757365726c6f67696e6964223b733a32303a22737570657261646d696e40676d61696c2e636f6d223b733a31303a2266697273746c6f67696e223b733a313a2230223b733a31353a227365637572697479656e61626c6564223b733a313a2231223b733a32313a22726573657470617373776f72647265717569726564223b693a313b7d, 1366532639, '2013-04-21 12:34:42', NULL, '2013-04-21 07:25:00', NULL, NULL),
('r98gb42chv1t67iitjo9343nd2', 'df3025e157f07d8defd08d0fb7c5843f', 0x6164646d65726368616e747c613a313a7b733a373a2273756363657373223b4e3b7d4d79506f7274616c7c613a363a7b733a333a22617070223b733a353a2261646d696e223b733a31393a2269734a617661736372697074456e61626c6564223b693a303b733a31313a22656d7074796c61796f7574223b733a31373a2261646d696e2f656d7074796c61796f7574223b733a363a226c61796f7574223b733a31323a2261646d696e2f6c61796f7574223b733a373a226661696c757265223b4e3b733a373a2273756363657373223b4e3b7d, 1366138055, '2013-04-16 20:50:21', NULL, '2013-04-16 18:37:36', NULL, NULL),
('rbfnd655br5qk28729u13ecus0', '5c8a8ffed19567e500dc1d7127309813', 0x4d79506f7274616c7c613a32303a7b733a333a22617070223b733a353a2261646d696e223b733a31393a2269734a617661736372697074456e61626c6564223b693a303b733a31313a22656d7074796c61796f7574223b733a31373a2261646d696e2f656d7074796c61796f7574223b733a363a226c61796f7574223b733a31323a2261646d696e2f6c61796f7574223b733a373a226661696c757265223b4e3b733a373a2273756363657373223b4e3b733a31353a2270617373776f726445787069726564223b733a313a2232223b733a383a226c6f67676564496e223b693a313b733a383a227573657274797065223b733a303a22223b733a343a22726f6c65223b733a31303a22537570657261646d696e223b733a383a22757365726e616d65223b733a31343a22537570657241646d696e2b474747223b733a31303a2275736572747970656964223b4e3b733a363a22726f6c656964223b733a313a2235223b733a363a22757365726964223b733a323a223634223b733a393a2275736572656d61696c223b733a32323a22737570657261646d696e253430676d61696c2e636f6d223b733a383a227072696f72697479223b733a313a2231223b733a31313a22757365726c6f67696e6964223b733a32303a22737570657261646d696e40676d61696c2e636f6d223b733a31303a2266697273746c6f67696e223b733a313a2230223b733a31353a227365637572697479656e61626c6564223b733a313a2231223b733a32313a22726573657470617373776f72647265717569726564223b693a313b7d6164646d65726368616e747c613a313a7b733a373a2273756363657373223b4e3b7d, 1366719799, '2013-04-23 16:53:57', NULL, '2013-04-23 11:24:20', NULL, NULL),
('rkem3c568e53k8k1pgc61p9t83', '5c8a8ffed19567e500dc1d7127309813', 0x4d79506f7274616c7c613a32303a7b733a333a22617070223b733a353a2261646d696e223b733a31393a2269734a617661736372697074456e61626c6564223b693a303b733a31313a22656d7074796c61796f7574223b733a31373a2261646d696e2f656d7074796c61796f7574223b733a363a226c61796f7574223b733a31323a2261646d696e2f6c61796f7574223b733a373a226661696c757265223b4e3b733a373a2273756363657373223b4e3b733a31353a2270617373776f726445787069726564223b733a313a2232223b733a383a226c6f67676564496e223b693a313b733a383a227573657274797065223b733a303a22223b733a343a22726f6c65223b733a31303a22537570657261646d696e223b733a383a22757365726e616d65223b733a31343a22537570657241646d696e2b474747223b733a31303a2275736572747970656964223b4e3b733a363a22726f6c656964223b733a313a2235223b733a363a22757365726964223b733a323a223634223b733a393a2275736572656d61696c223b733a32323a22737570657261646d696e253430676d61696c2e636f6d223b733a383a227072696f72697479223b733a313a2231223b733a31313a22757365726c6f67696e6964223b733a32303a22737570657261646d696e40676d61696c2e636f6d223b733a31303a2266697273746c6f67696e223b733a313a2230223b733a31353a227365637572697479656e61626c6564223b733a313a2231223b733a32313a22726573657470617373776f72647265717569726564223b693a313b7d6164646d65726368616e747c613a313a7b733a373a2273756363657373223b4e3b7d, 1365790857, '2013-04-12 21:39:27', NULL, '2013-04-12 18:10:58', NULL, NULL),
('s27qu48ji52i2ehm4svj21hdr6', 'a5f724d1b119d6198c6e59fe73fc0807', 0x4d79506f7274616c7c613a32303a7b733a333a22617070223b733a353a2261646d696e223b733a31393a2269734a617661736372697074456e61626c6564223b693a303b733a31313a22656d7074796c61796f7574223b733a31373a2261646d696e2f656d7074796c61796f7574223b733a363a226c61796f7574223b733a31323a2261646d696e2f6c61796f7574223b733a373a226661696c757265223b4e3b733a373a2273756363657373223b733a303a22223b733a31353a2270617373776f726445787069726564223b733a313a2232223b733a383a226c6f67676564496e223b693a313b733a383a227573657274797065223b733a303a22223b733a343a22726f6c65223b733a31303a22537570657261646d696e223b733a383a22757365726e616d65223b733a31343a22537570657241646d696e2b474747223b733a31303a2275736572747970656964223b4e3b733a363a22726f6c656964223b733a313a2235223b733a363a22757365726964223b733a323a223634223b733a393a2275736572656d61696c223b733a32323a22737570657261646d696e253430676d61696c2e636f6d223b733a383a227072696f72697479223b733a313a2231223b733a31313a22757365726c6f67696e6964223b733a32303a22737570657261646d696e40676d61696c2e636f6d223b733a31303a2266697273746c6f67696e223b733a313a2230223b733a31353a227365637572697479656e61626c6564223b733a313a2231223b733a32313a22726573657470617373776f72647265717569726564223b693a303b7d6164646d65726368616e747c613a313a7b733a373a2273756363657373223b4e3b7d, 1365524885, '2013-04-09 21:04:22', NULL, '2013-04-09 16:18:06', NULL, NULL),
('teqbv9081epmjiaboq7d6vplh4', 'a5f724d1b119d6198c6e59fe73fc0807', 0x4d79506f7274616c7c613a313a7b733a383a226c6f67676564496e223b4e3b7d, 1365082422, '2013-04-04 17:25:31', NULL, '2013-04-04 13:30:43', NULL, NULL),
('u1bbr1ls58hd50l4f5la1jkfj6', 'a5f724d1b119d6198c6e59fe73fc0807', 0x4d79506f7274616c7c613a363a7b733a333a22617070223b733a353a2261646d696e223b733a31393a2269734a617661736372697074456e61626c6564223b693a303b733a31313a22656d7074796c61796f7574223b733a31373a2261646d696e2f656d7074796c61796f7574223b733a363a226c61796f7574223b733a31323a2261646d696e2f6c61796f7574223b733a373a226661696c757265223b4e3b733a373a2273756363657373223b4e3b7d6164646d65726368616e747c613a313a7b733a373a2273756363657373223b4e3b7d, 1365311686, '2013-04-07 09:20:15', NULL, '2013-04-07 05:11:47', NULL, NULL),
('uck0hcqlienf13idt80mjqc104', 'a5f724d1b119d6198c6e59fe73fc0807', '', 1365352768, '2013-04-07 22:06:29', NULL, '2013-04-07 16:36:29', NULL, NULL),
('v0b5rmtk9qi7dbl3g67pat5hn6', 'd18e6bdfae14d5729064b3312d223e11', 0x4d79506f7274616c7c613a32313a7b733a333a22617070223b733a353a2261646d696e223b733a31393a2269734a617661736372697074456e61626c6564223b693a303b733a31313a22656d7074796c61796f7574223b733a31373a2261646d696e2f656d7074796c61796f7574223b733a363a226c61796f7574223b733a31323a2261646d696e2f6c61796f7574223b733a373a226661696c757265223b4e3b733a373a2273756363657373223b4e3b733a31353a2270617373776f726445787069726564223b733a313a2232223b733a383a226c6f67676564496e223b693a313b733a383a227573657274797065223b733a303a22223b733a343a22726f6c65223b733a31303a22537570657261646d696e223b733a383a22757365726e616d65223b733a31343a22537570657241646d696e2b474747223b733a31303a2275736572747970656964223b4e3b733a363a22726f6c656964223b733a313a2235223b733a363a22757365726964223b733a323a223634223b733a393a2275736572656d61696c223b733a32323a22737570657261646d696e253430676d61696c2e636f6d223b733a383a227072696f72697479223b733a313a2231223b733a31313a22757365726c6f67696e6964223b733a32303a22737570657261646d696e40676d61696c2e636f6d223b733a31303a2266697273746c6f67696e223b733a313a2230223b733a31353a227365637572697479656e61626c6564223b733a313a2231223b733a32313a22726573657470617373776f72647265717569726564223b693a313b733a31333a2276616c69646174656572726f72223b4e3b7d6164646d65726368616e747c613a313a7b733a373a2273756363657373223b4e3b7d, 1367997626, '2013-05-08 11:21:07', NULL, '2013-05-08 06:21:27', NULL, NULL),
('v65lrphk51li2940j5gjmt4607', 'a5f724d1b119d6198c6e59fe73fc0807', 0x6164646d65726368616e747c613a313a7b733a373a2273756363657373223b4e3b7d4d79506f7274616c7c613a363a7b733a333a22617070223b733a353a2261646d696e223b733a31393a2269734a617661736372697074456e61626c6564223b693a303b733a31313a22656d7074796c61796f7574223b733a31373a2261646d696e2f656d7074796c61796f7574223b733a363a226c61796f7574223b733a31323a2261646d696e2f6c61796f7574223b733a373a226661696c757265223b4e3b733a373a2273756363657373223b4e3b7d, 1365352135, '2013-04-07 21:27:33', NULL, '2013-04-07 16:25:56', NULL, NULL),
('veso1uforce8m3ndj7u1ko6gj1', 'd18e6bdfae14d5729064b3312d223e11', 0x6164646d65726368616e747c613a313a7b733a373a2273756363657373223b4e3b7d4d79506f7274616c7c613a363a7b733a333a22617070223b733a353a2261646d696e223b733a31393a2269734a617661736372697074456e61626c6564223b693a303b733a31313a22656d7074796c61796f7574223b733a31373a2261646d696e2f656d7074796c61796f7574223b733a363a226c61796f7574223b733a31323a2261646d696e2f6c61796f7574223b733a373a226661696c757265223b4e3b733a373a2273756363657373223b4e3b7d, 1369000173, '2013-05-20 01:07:14', NULL, '2013-05-19 20:50:34', NULL, NULL),
('vjvl4e22edh6boi18tmmrtk685', '3cf4c23e4201565642bf5b496a65f13e', 0x4d79506f7274616c7c613a363a7b733a333a22617070223b733a353a2261646d696e223b733a31393a2269734a617661736372697074456e61626c6564223b693a303b733a31313a22656d7074796c61796f7574223b733a31373a2261646d696e2f656d7074796c61796f7574223b733a363a226c61796f7574223b733a31323a2261646d696e2f6c61796f7574223b733a373a226661696c757265223b4e3b733a373a2273756363657373223b4e3b7d6164646d65726368616e747c613a313a7b733a373a2273756363657373223b4e3b7d, 1365271435, '2013-04-06 23:30:56', NULL, '2013-04-06 18:00:56', NULL, NULL),
('vs4ppnq8kgo5uja0c47mbtq8f3', '5c8a8ffed19567e500dc1d7127309813', 0x4d79506f7274616c7c613a32313a7b733a333a22617070223b733a353a2261646d696e223b733a31393a2269734a617661736372697074456e61626c6564223b693a303b733a31313a22656d7074796c61796f7574223b733a31373a2261646d696e2f656d7074796c61796f7574223b733a363a226c61796f7574223b733a31323a2261646d696e2f6c61796f7574223b733a373a226661696c757265223b4e3b733a373a2273756363657373223b4e3b733a31353a2270617373776f726445787069726564223b733a313a2232223b733a383a226c6f67676564496e223b693a313b733a383a227573657274797065223b733a303a22223b733a343a22726f6c65223b733a31303a22537570657261646d696e223b733a383a22757365726e616d65223b733a31343a22537570657241646d696e2b474747223b733a31303a2275736572747970656964223b4e3b733a363a22726f6c656964223b733a313a2235223b733a363a22757365726964223b733a323a223634223b733a393a2275736572656d61696c223b733a32323a22737570657261646d696e253430676d61696c2e636f6d223b733a383a227072696f72697479223b733a313a2231223b733a31313a22757365726c6f67696e6964223b733a32303a22737570657261646d696e40676d61696c2e636f6d223b733a31303a2266697273746c6f67696e223b733a313a2230223b733a31353a227365637572697479656e61626c6564223b733a313a2231223b733a32313a22726573657470617373776f72647265717569726564223b693a313b733a31333a2276616c69646174656572726f72223b4e3b7d6164646d65726368616e747c613a313a7b733a373a2273756363657373223b4e3b7d, 1368852806, '2013-05-18 09:22:59', NULL, '2013-05-18 03:54:28', NULL, NULL);

-- --------------------------------------------------------

--
-- Table structure for table `apmuseractivitylog`
--

CREATE TABLE IF NOT EXISTS `apmuseractivitylog` (
  `activitylogid` int(11) NOT NULL AUTO_INCREMENT COMMENT 'auto key column for user activity log',
  `userid` int(11) DEFAULT NULL COMMENT 'user for which the log is maintained',
  `useractionid` int(11) NOT NULL DEFAULT '1' COMMENT 'foreign key for user actions',
  `actionid` int(11) DEFAULT NULL COMMENT 'action for which the log is maintained',
  `actiondesc` varchar(255) NOT NULL COMMENT 'action log description for which the log is maintained',
  `createddatetime` datetime NOT NULL COMMENT 'created date time for this record',
  `updateddatetime` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'record updated date time',
  `deleteddatetime` datetime DEFAULT NULL COMMENT 'deleted date for this record',
  `statusid` int(11) NOT NULL COMMENT 'status of this record and foreign key for recordsstate table',
  `createdby` varchar(255) DEFAULT NULL COMMENT 'Stores MySQL User Created Details',
  `lastupdatedby` varchar(255) DEFAULT NULL COMMENT 'Stores MySQL User last updated Details',
  PRIMARY KEY (`activitylogid`),
  KEY `FK_apmuseractivitylog_actionid_apmmasteractions` (`actionid`),
  KEY `FK_apmuseractivitylog_statusid_apmmasterrecordsstate` (`statusid`),
  KEY `FK_apmuseractivitylog_userid_apmusers` (`userid`),
  KEY `FK_apmuseractivitylog_useractionid_apmmasteruseractions` (`useractionid`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 COMMENT='all user activity logs are maintained here' AUTO_INCREMENT=622 ;

--
-- Dumping data for table `apmuseractivitylog`
--

INSERT INTO `apmuseractivitylog` (`activitylogid`, `userid`, `useractionid`, `actionid`, `actiondesc`, `createddatetime`, `updateddatetime`, `deleteddatetime`, `statusid`, `createdby`, `lastupdatedby`) VALUES
(196, NULL, 39, 9, 'Unable to create merchant with Merchant 101 as the merchant title already exists.', '2013-04-20 16:10:41', '2013-04-20 10:40:41', NULL, 1, NULL, NULL),
(549, 83, 5, 9, 'User created with email superadmin2@gmail.com and userid superadmin2@gmail.com by admin 64', '2013-06-02 13:55:29', '2013-06-02 08:25:29', NULL, 1, NULL, NULL),
(550, 83, 1, 3, 'Invalid password for 83', '2013-06-02 13:56:43', '2013-06-02 08:26:43', NULL, 1, NULL, NULL),
(551, 83, 1, 3, 'Invalid password for 83', '2013-06-02 13:57:11', '2013-06-02 08:27:11', NULL, 1, NULL, NULL),
(552, 83, 1, 3, 'User succefully logged in with 83', '2013-06-02 13:58:12', '2013-06-02 08:28:12', NULL, 1, NULL, NULL),
(553, 83, 2, 2, 'User has updated his password with userid 83', '2013-06-02 14:18:51', '2013-06-02 08:48:51', NULL, 1, NULL, NULL),
(554, 83, 3, 2, 'Security questions were added for userid 83', '2013-06-02 14:18:52', '2013-06-02 08:48:52', NULL, 1, NULL, NULL),
(555, 83, 1, 3, 'User succefully logged in with 83', '2013-06-02 14:20:14', '2013-06-02 08:50:14', NULL, 1, NULL, NULL),
(556, 83, 1, 3, 'User succefully logged in with 83', '2013-06-02 14:21:37', '2013-06-02 08:51:37', NULL, 1, NULL, NULL),
(557, 84, 5, 9, 'User created with email admin1@gmail.com and userid admin1@gmail.com by admin 83', '2013-06-02 14:26:02', '2013-06-02 08:56:02', NULL, 1, NULL, NULL),
(558, 83, 1, 3, 'User succefully logged in with 83', '2013-06-02 14:31:51', '2013-06-02 09:01:51', NULL, 1, NULL, NULL),
(559, 84, 1, 3, 'User succefully logged in with 84', '2013-06-02 14:32:57', '2013-06-02 09:02:57', NULL, 1, NULL, NULL),
(560, 84, 2, 2, 'User has updated his password with userid 84', '2013-06-02 15:11:13', '2013-06-02 09:41:13', NULL, 1, NULL, NULL),
(561, 84, 3, 2, 'Security questions were added for userid 84', '2013-06-02 15:11:14', '2013-06-02 09:41:14', NULL, 1, NULL, NULL),
(562, 84, 1, 3, 'User succefully logged in with 84', '2013-06-02 15:11:35', '2013-06-02 09:41:35', NULL, 1, NULL, NULL),
(563, 85, 5, 9, 'User created with email merchantadmin1@gmail.com and userid merchantadmin1@gmail.com by admin 84', '2013-06-02 15:15:52', '2013-06-02 09:45:52', NULL, 1, NULL, NULL),
(564, 85, 1, 3, 'User succefully logged in with 85', '2013-06-02 15:16:57', '2013-06-02 09:46:57', NULL, 1, NULL, NULL),
(565, 85, 2, 2, 'User has updated his password with userid 85', '2013-06-02 15:17:21', '2013-06-02 09:47:21', NULL, 1, NULL, NULL),
(566, 85, 3, 2, 'Security questions were added for userid 85', '2013-06-02 15:17:22', '2013-06-02 09:47:22', NULL, 1, NULL, NULL),
(567, 85, 1, 3, 'User succefully logged in with 85', '2013-06-02 15:17:53', '2013-06-02 09:47:53', NULL, 1, NULL, NULL),
(568, 83, 1, 3, 'User succefully logged in with 83', '2013-06-06 22:13:31', '2013-06-06 16:43:31', NULL, 1, NULL, NULL),
(569, 83, 66, NULL, 'Product price updated with title product_price_description 22 and product_price_id 2 by admin 83', '2013-06-06 22:32:28', '2013-06-06 17:02:28', NULL, 1, NULL, NULL),
(570, 83, 66, NULL, 'Product price updated with title product_price_description 11 and product_price_id 1 by admin 83', '2013-06-06 22:32:28', '2013-06-06 17:02:28', NULL, 1, NULL, NULL),
(571, 83, 66, NULL, 'Product price updated with title product_price_description 22 and product_price_id 2 by admin 83', '2013-06-06 22:35:35', '2013-06-06 17:05:35', NULL, 1, NULL, NULL),
(572, 83, 66, NULL, 'Product price updated with title product_price_description 11 and product_price_id 1 by admin 83', '2013-06-06 22:35:35', '2013-06-06 17:05:35', NULL, 1, NULL, NULL),
(573, 83, 66, NULL, 'Product price updated with title product_price_description 22 and product_price_id 2 by admin 83', '2013-06-06 22:37:57', '2013-06-06 17:07:57', NULL, 1, NULL, NULL),
(574, 83, 66, NULL, 'Product price updated with title product_price_description 11 and product_price_id 1 by admin 83', '2013-06-06 22:37:57', '2013-06-06 17:07:57', NULL, 1, NULL, NULL),
(575, 83, 1, 3, 'User succefully logged in with 83', '2013-06-08 08:15:44', '2013-06-08 02:45:44', NULL, 1, NULL, NULL),
(576, 83, 38, NULL, 'Merchant with merchant_id 6 was Deleted by admin with adminid 83', '2013-06-08 08:28:55', '2013-06-08 02:58:55', NULL, 1, NULL, NULL),
(577, 83, 38, NULL, 'Merchant with merchant_id 6 was Deleted by admin with adminid 83', '2013-06-08 08:37:39', '2013-06-08 03:07:39', NULL, 1, NULL, NULL),
(578, 83, 72, NULL, 'Product with product_id 6 was Deleted by admin with adminid 83', '2013-06-08 08:40:58', '2013-06-08 03:10:58', NULL, 1, NULL, NULL),
(579, 83, 60, 9, 'Procudt created with title 86868 and product_id 7 by admin 83', '2013-06-08 08:43:49', '2013-06-08 03:13:49', NULL, 1, NULL, NULL),
(580, 83, 70, NULL, 'Product with product_id 7 was Locked by admin with adminid 83', '2013-06-08 08:44:02', '2013-06-08 03:14:02', NULL, 1, NULL, NULL),
(581, 83, 71, NULL, 'Product with product_id 7 was Activated by admin with adminid 83', '2013-06-08 08:44:14', '2013-06-08 03:14:14', NULL, 1, NULL, NULL),
(582, 83, 1, 3, 'Invalid password for 83', '2013-06-08 10:06:21', '2013-06-08 04:36:21', NULL, 1, NULL, NULL),
(583, 83, 1, 3, 'User succefully logged in with 83', '2013-06-08 10:06:40', '2013-06-08 04:36:40', NULL, 1, NULL, NULL),
(584, 84, 16, 37, 'User with userid 84 was Locked by admin with userid 83', '2013-06-08 10:07:33', '2013-06-08 04:37:33', NULL, 1, NULL, NULL),
(585, 84, 17, 38, 'User with userid 84 was Activated by admin with userid 83', '2013-06-08 10:07:51', '2013-06-08 04:37:51', NULL, 1, NULL, NULL),
(586, 84, 15, 12, 'Details were updated for userid 84 by 83', '2013-06-08 10:08:21', '2013-06-08 04:38:21', NULL, 1, NULL, NULL),
(587, 84, 15, 12, 'Details were updated for userid 84 by 83', '2013-06-08 10:09:01', '2013-06-08 04:39:01', NULL, 1, NULL, NULL),
(588, 83, 1, 3, 'User succefully logged in with 83', '2013-06-08 13:11:54', '2013-06-08 07:41:54', NULL, 1, NULL, NULL),
(589, 83, 25, 9, 'Unable to create category with category 1 as the category title already exists.', '2013-06-08 13:12:25', '2013-06-08 07:42:25', NULL, 1, NULL, NULL),
(590, 83, 25, 9, 'Category created with title category 111 and category_id 31 by admin 83', '2013-06-08 13:12:42', '2013-06-08 07:42:42', NULL, 1, NULL, NULL),
(591, 84, 13, NULL, 'forgot user password for the id 84', '2013-06-08 13:14:20', '2013-06-08 07:44:20', NULL, 1, NULL, NULL),
(592, 83, 67, NULL, 'Product categories created with title 86868 and product_category_id 82 by admin 83', '2013-06-08 16:48:38', '2013-06-08 11:18:38', NULL, 1, NULL, NULL),
(593, 83, 67, NULL, 'Product categories created with title 86868 and product_category_id 83 by admin 83', '2013-06-08 16:49:15', '2013-06-08 11:19:15', NULL, 1, NULL, NULL),
(594, 83, 67, NULL, 'Product categories created with title 86868 and product_category_id 84 by admin 83', '2013-06-08 16:51:01', '2013-06-08 11:21:01', NULL, 1, NULL, NULL),
(595, 83, 67, NULL, 'Product categories created with title 86868 and product_category_id 85 by admin 83', '2013-06-08 16:51:01', '2013-06-08 11:21:01', NULL, 1, NULL, NULL),
(596, 83, 1, 3, 'User succefully logged in with 83', '2013-06-08 20:55:10', '2013-06-08 15:25:10', NULL, 1, NULL, NULL),
(597, 83, 62, NULL, 'Product image created with title 86868 and product_image_id 16 by admin 83', '2013-06-08 21:19:49', '2013-06-08 15:49:49', NULL, 1, NULL, NULL),
(598, 83, 62, NULL, 'Product image created with title 86868 and product_image_id 17 by admin 83', '2013-06-08 21:19:49', '2013-06-08 15:49:49', NULL, 1, NULL, NULL),
(599, 83, 62, NULL, 'Product image created with title 86868 and product_image_id 18 by admin 83', '2013-06-08 21:58:52', '2013-06-08 16:28:52', NULL, 1, NULL, NULL),
(600, 83, 62, NULL, 'Product image created with title 86868 and product_image_id 19 by admin 83', '2013-06-08 21:58:52', '2013-06-08 16:28:52', NULL, 1, NULL, NULL),
(601, 83, 62, NULL, 'Product image created with title 86868 and product_image_id 20 by admin 83', '2013-06-08 21:59:35', '2013-06-08 16:29:35', NULL, 1, NULL, NULL),
(602, 83, 63, NULL, 'Product image with product_image_id 20 was Deleted by admin with adminid 83', '2013-06-08 22:01:41', '2013-06-08 16:31:41', NULL, 1, NULL, NULL),
(603, 83, 69, NULL, 'Procudt updated with title Product 7 and product_id 7 by admin 83', '2013-06-08 22:03:50', '2013-06-08 16:33:50', NULL, 1, NULL, NULL),
(604, 83, 60, 9, 'Procudt created with title Product 8 and product_id 8 by admin 83', '2013-06-08 22:06:22', '2013-06-08 16:36:22', NULL, 1, NULL, NULL),
(605, 83, 66, NULL, 'Product price created with title XXL and product_price_id 3 by admin 83', '2013-06-08 22:09:24', '2013-06-08 16:39:24', NULL, 1, NULL, NULL),
(606, 83, 66, NULL, 'Product price created with title XL and product_price_id 4 by admin 83', '2013-06-08 22:09:24', '2013-06-08 16:39:24', NULL, 1, NULL, NULL),
(607, 83, 66, NULL, 'Product price created with title L and product_price_id 5 by admin 83', '2013-06-08 22:09:24', '2013-06-08 16:39:24', NULL, 1, NULL, NULL),
(608, 83, 66, NULL, 'Product price created with title M and product_price_id 6 by admin 83', '2013-06-08 22:09:24', '2013-06-08 16:39:24', NULL, 1, NULL, NULL),
(609, 83, 66, NULL, 'Product price created with title S and product_price_id 7 by admin 83', '2013-06-08 22:09:24', '2013-06-08 16:39:24', NULL, 1, NULL, NULL),
(610, 83, 62, NULL, 'Product image created with title Product 8 and product_image_id 21 by admin 83', '2013-06-08 22:10:24', '2013-06-08 16:40:24', NULL, 1, NULL, NULL),
(611, 83, 62, NULL, 'Product image created with title Product 8 and product_image_id 22 by admin 83', '2013-06-08 22:10:24', '2013-06-08 16:40:24', NULL, 1, NULL, NULL),
(612, 83, 62, NULL, 'Product image created with title Product 8 and product_image_id 23 by admin 83', '2013-06-08 22:10:24', '2013-06-08 16:40:24', NULL, 1, NULL, NULL),
(613, 83, 67, NULL, 'Product categories created with title Product 8 and product_category_id 86 by admin 83', '2013-06-08 22:12:02', '2013-06-08 16:42:02', NULL, 1, NULL, NULL),
(614, 83, 67, NULL, 'Product categories created with title Product 8 and product_category_id 87 by admin 83', '2013-06-08 22:12:02', '2013-06-08 16:42:02', NULL, 1, NULL, NULL),
(615, 83, 67, NULL, 'Product categories created with title Product 8 and product_category_id 88 by admin 83', '2013-06-08 22:12:02', '2013-06-08 16:42:02', NULL, 1, NULL, NULL),
(616, 83, 67, NULL, 'Product categories created with title Product 8 and product_category_id 89 by admin 83', '2013-06-08 22:12:02', '2013-06-08 16:42:02', NULL, 1, NULL, NULL),
(617, 83, 68, NULL, 'Product attribute value created with product_price_id10  by admin 83', '2013-06-08 22:13:23', '2013-06-08 16:43:23', NULL, 1, NULL, NULL),
(618, 83, 68, NULL, 'Product attribute value created with product_price_id11  by admin 83', '2013-06-08 22:13:23', '2013-06-08 16:43:23', NULL, 1, NULL, NULL),
(619, 83, 68, NULL, 'Product attribute value created with product_price_id12  by admin 83', '2013-06-08 22:13:23', '2013-06-08 16:43:23', NULL, 1, NULL, NULL),
(620, 83, 68, NULL, 'Product attribute value created with product_price_id13  by admin 83', '2013-06-08 22:13:23', '2013-06-08 16:43:23', NULL, 1, NULL, NULL),
(621, 83, 68, NULL, 'Product attribute value created with product_price_id14  by admin 83', '2013-06-08 22:13:23', '2013-06-08 16:43:23', NULL, 1, NULL, NULL);

-- --------------------------------------------------------

--
-- Table structure for table `apmuserrolemapping`
--

CREATE TABLE IF NOT EXISTS `apmuserrolemapping` (
  `usermapid` int(11) NOT NULL AUTO_INCREMENT COMMENT 'auto key column for usermapping with the role',
  `roleid` int(11) NOT NULL COMMENT 'role to which user is mapped',
  `userid` int(11) NOT NULL COMMENT 'user for which a role is assigned',
  `userparentid` int(11) DEFAULT '0' COMMENT 'userid based on usertypeid in roles table',
  `createddatetime` datetime NOT NULL COMMENT 'created date time for this record',
  `updateddatetime` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'record updated date time',
  `deleteddatetime` datetime DEFAULT NULL COMMENT 'deleted date for this record',
  `statusid` int(11) NOT NULL COMMENT 'status of this record and foreign key for recordsstate table',
  `createdby` varchar(255) DEFAULT NULL COMMENT 'Stores MySQL User Created Details',
  `lastupdatedby` varchar(255) DEFAULT NULL COMMENT 'Stores MySQL User last updated Details',
  PRIMARY KEY (`usermapid`),
  UNIQUE KEY `UQ_userid_roleid_appid` (`userid`,`roleid`),
  KEY `FK_apmuserrolemapping_roleid_apmmasterroles` (`roleid`),
  KEY `FK_apmuserrolemapping_statusid_apmmasterrecordsstate` (`statusid`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 COMMENT='all role mappings with the users are done here' AUTO_INCREMENT=78 ;

--
-- Dumping data for table `apmuserrolemapping`
--

INSERT INTO `apmuserrolemapping` (`usermapid`, `roleid`, `userid`, `userparentid`, `createddatetime`, `updateddatetime`, `deleteddatetime`, `statusid`, `createdby`, `lastupdatedby`) VALUES
(75, 5, 83, 0, '2013-06-02 13:55:29', '2013-06-02 08:25:29', NULL, 1, NULL, NULL),
(76, 8, 84, 0, '2013-06-02 14:26:02', '2013-06-02 08:56:02', NULL, 1, NULL, NULL),
(77, 9, 85, 0, '2013-06-02 15:15:52', '2013-06-02 09:45:52', NULL, 1, NULL, NULL);

-- --------------------------------------------------------

--
-- Table structure for table `apmusers`
--

CREATE TABLE IF NOT EXISTS `apmusers` (
  `userid` int(11) NOT NULL AUTO_INCREMENT COMMENT 'auto key column for users',
  `firstname` varchar(20) NOT NULL COMMENT 'first name of the registered user',
  `lastname` varchar(20) NOT NULL COMMENT 'last name of the registered user',
  `userloginid` varchar(50) NOT NULL COMMENT 'User login id as email id',
  `emailid` varchar(50) NOT NULL COMMENT 'email id of the registered suer',
  `password` varchar(255) NOT NULL COMMENT 'password for the registered user to access his account',
  `phonenumber` bigint(10) DEFAULT NULL,
  `isfirstpass` int(11) NOT NULL DEFAULT '1' COMMENT 'check for first time login',
  `issecured` int(11) NOT NULL DEFAULT '0' COMMENT 'check for security questions',
  `passcounter` int(11) NOT NULL DEFAULT '0' COMMENT 'Wrong Password counter',
  `seccounter` int(11) NOT NULL DEFAULT '0' COMMENT 'Wrong Security question counter',
  `createddatetime` datetime NOT NULL COMMENT 'created date time for this record',
  `updateddatetime` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'record updated date time',
  `deleteddatetime` datetime DEFAULT NULL COMMENT 'deleted date for this record',
  `statusid` int(11) NOT NULL COMMENT 'status of this record and foreign key for recordsstate table',
  `createdby` varchar(255) DEFAULT NULL COMMENT 'Record created user',
  `lastupdatedby` varchar(255) DEFAULT NULL COMMENT 'Record updated user',
  PRIMARY KEY (`userid`),
  UNIQUE KEY `UQ_userloginid` (`userloginid`),
  KEY `FK_apmusers_statusid_apmmasterrecordsstate` (`statusid`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 COMMENT='all users for the apm portal are entered here' AUTO_INCREMENT=86 ;

--
-- Dumping data for table `apmusers`
--

INSERT INTO `apmusers` (`userid`, `firstname`, `lastname`, `userloginid`, `emailid`, `password`, `phonenumber`, `isfirstpass`, `issecured`, `passcounter`, `seccounter`, `createddatetime`, `updateddatetime`, `deleteddatetime`, `statusid`, `createdby`, `lastupdatedby`) VALUES
(83, 'Superadmin', 'One', 'superadmin@gmail.com', 'superadmin@gmail.com', '07480fb9e85b9396af06f006cf1c95024af2531c65fb505cfbd0add1e2f31573', 9876543211, 0, 1, 0, 0, '2013-06-02 13:55:29', '2013-06-08 04:36:40', NULL, 1, NULL, NULL),
(84, 'Admin', 'One', 'admin1@gmail.com', 'admin1@gmail.com', '07480fb9e85b9396af06f006cf1c95024af2531c65fb505cfbd0add1e2f31573', 9876543211, 0, 1, 0, 0, '2013-06-02 14:26:02', '2013-06-08 04:39:01', NULL, 1, NULL, NULL),
(85, 'Merchant Admin', 'One', 'merchantadmin1@gmail.com', 'merchantadmin1@gmail.com', '07480fb9e85b9396af06f006cf1c95024af2531c65fb505cfbd0add1e2f31573', 9876543211, 0, 1, 0, 0, '2013-06-02 15:15:52', '2013-06-02 09:47:22', NULL, 1, NULL, NULL);

-- --------------------------------------------------------

--
-- Table structure for table `com_country`
--

CREATE TABLE IF NOT EXISTS `com_country` (
  `country_id` int(11) NOT NULL AUTO_INCREMENT,
  `zone_id` int(11) NOT NULL DEFAULT '1',
  `country_name` varchar(64) DEFAULT NULL,
  `country_3_code` char(3) DEFAULT NULL,
  `country_2_code` char(2) DEFAULT NULL,
  `country_flag` varchar(255) NOT NULL,
  `createddatetime` datetime NOT NULL,
  `updateddatetime` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `deleteddatetime` datetime NOT NULL,
  `statusid` int(11) NOT NULL,
  `createdby` varchar(255) NOT NULL,
  `lastupdatedby` varchar(255) NOT NULL,
  PRIMARY KEY (`country_id`),
  KEY `idx_country_name` (`country_name`),
  KEY `FK_com_country_1` (`statusid`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 COMMENT='all country records' AUTO_INCREMENT=242 ;

--
-- Dumping data for table `com_country`
--

INSERT INTO `com_country` (`country_id`, `zone_id`, `country_name`, `country_3_code`, `country_2_code`, `country_flag`, `createddatetime`, `updateddatetime`, `deleteddatetime`, `statusid`, `createdby`, `lastupdatedby`) VALUES
(1, 1, 'Afghanistan', 'AFG', 'AF', 'af-t.gif', '0000-00-00 00:00:00', '2013-04-14 06:35:27', '0000-00-00 00:00:00', 1, '', ''),
(2, 1, 'Albania', 'ALB', 'AL', 'al-t.gif', '0000-00-00 00:00:00', '2013-04-14 06:35:27', '0000-00-00 00:00:00', 1, '', ''),
(3, 1, 'Algeria', 'DZA', 'DZ', 'dz-t.gif', '0000-00-00 00:00:00', '2013-04-14 06:35:27', '0000-00-00 00:00:00', 1, '', ''),
(4, 1, 'American Samoa', 'ASM', 'AS', 'as-t.gif', '0000-00-00 00:00:00', '2013-04-14 06:35:27', '0000-00-00 00:00:00', 1, '', ''),
(5, 1, 'Andorra', 'AND', 'AD', 'ad-t.gif', '0000-00-00 00:00:00', '2013-04-14 06:35:27', '0000-00-00 00:00:00', 1, '', ''),
(6, 1, 'Angola', 'AGO', 'AO', 'ao-t.gif', '0000-00-00 00:00:00', '2013-04-14 06:35:27', '0000-00-00 00:00:00', 1, '', ''),
(7, 1, 'Anguilla', 'AIA', 'AI', 'ai-t.gif', '0000-00-00 00:00:00', '2013-04-14 06:35:27', '0000-00-00 00:00:00', 1, '', ''),
(8, 1, 'Antarctica', 'ATA', 'AQ', 'aq-t.gif', '0000-00-00 00:00:00', '2013-04-14 06:35:27', '0000-00-00 00:00:00', 1, '', ''),
(9, 1, 'Antigua and Barbuda', 'ATG', 'AG', 'ag-t.png', '0000-00-00 00:00:00', '2013-04-14 06:35:27', '0000-00-00 00:00:00', 1, '', ''),
(10, 1, 'Argentina', 'ARG', 'AR', 'ar-t.gif', '0000-00-00 00:00:00', '2013-04-14 06:35:27', '0000-00-00 00:00:00', 1, '', ''),
(11, 1, 'Armenia', 'ARM', 'AM', 'am-t.gif', '0000-00-00 00:00:00', '2013-04-14 06:35:27', '0000-00-00 00:00:00', 1, '', ''),
(12, 1, 'Aruba', 'ABW', 'AW', 'aw-t.gif', '0000-00-00 00:00:00', '2013-04-14 06:35:27', '0000-00-00 00:00:00', 1, '', ''),
(13, 1, 'Australia', 'AUS', 'AU', 'au-t.gif', '0000-00-00 00:00:00', '2013-04-14 06:35:27', '0000-00-00 00:00:00', 1, '', ''),
(14, 1, 'Austria', 'AUT', 'AT', 'at-t.gif', '0000-00-00 00:00:00', '2013-04-14 06:35:27', '0000-00-00 00:00:00', 1, '', ''),
(15, 1, 'Azerbaijan', 'AZE', 'AZ', 'az-t.gif', '0000-00-00 00:00:00', '2013-04-14 06:35:27', '0000-00-00 00:00:00', 1, '', ''),
(16, 1, 'Bahamas', 'BHS', 'BS', 'bs-t.gif', '0000-00-00 00:00:00', '2013-04-14 06:35:27', '0000-00-00 00:00:00', 1, '', ''),
(17, 1, 'Bahrain', 'BHR', 'BH', 'bh-t.gif', '0000-00-00 00:00:00', '2013-04-14 06:35:27', '0000-00-00 00:00:00', 1, '', ''),
(18, 1, 'Bangladesh', 'BGD', 'BD', 'bd-t.gif', '0000-00-00 00:00:00', '2013-04-14 06:35:27', '0000-00-00 00:00:00', 1, '', ''),
(19, 1, 'Barbados', 'BRB', 'BB', 'bb-t.gif', '0000-00-00 00:00:00', '2013-04-14 06:35:27', '0000-00-00 00:00:00', 1, '', ''),
(20, 1, 'Belarus', 'BLR', 'BY', 'by-t.gif', '0000-00-00 00:00:00', '2013-04-14 06:35:27', '0000-00-00 00:00:00', 1, '', ''),
(21, 1, 'Belgium', 'BEL', 'BE', 'be-t.gif', '0000-00-00 00:00:00', '2013-04-14 06:35:27', '0000-00-00 00:00:00', 1, '', ''),
(22, 1, 'Belize', 'BLZ', 'BZ', 'bz-t.gif', '0000-00-00 00:00:00', '2013-04-14 06:35:27', '0000-00-00 00:00:00', 1, '', ''),
(23, 1, 'Benin', 'BEN', 'BJ', 'bj-t.gif', '0000-00-00 00:00:00', '2013-04-14 06:35:27', '0000-00-00 00:00:00', 1, '', ''),
(24, 1, 'Bermuda', 'BMU', 'BM', 'bm-t.gif', '0000-00-00 00:00:00', '2013-04-14 06:35:27', '0000-00-00 00:00:00', 1, '', ''),
(25, 1, 'Bhutan', 'BTN', 'BT', 'bt-t.gif', '0000-00-00 00:00:00', '2013-04-14 06:35:27', '0000-00-00 00:00:00', 1, '', ''),
(26, 1, 'Bolivia', 'BOL', 'BO', 'bo-t.gif', '0000-00-00 00:00:00', '2013-04-14 06:35:27', '0000-00-00 00:00:00', 1, '', ''),
(27, 1, 'Bosnia and Herzegowina', 'BIH', 'BA', 'ba-t.gif', '0000-00-00 00:00:00', '2013-04-14 06:35:27', '0000-00-00 00:00:00', 1, '', ''),
(28, 1, 'Botswana', 'BWA', 'BW', 'bw-t.gif', '0000-00-00 00:00:00', '2013-04-14 06:35:27', '0000-00-00 00:00:00', 1, '', ''),
(29, 1, 'Bouvet Island', 'BVT', 'BV', 'bv-t.gif', '0000-00-00 00:00:00', '2013-04-14 06:35:27', '0000-00-00 00:00:00', 1, '', ''),
(30, 1, 'Brazil', 'BRA', 'BR', 'br-t.gif', '0000-00-00 00:00:00', '2013-04-14 06:35:27', '0000-00-00 00:00:00', 1, '', ''),
(31, 1, 'British Indian Ocean Territory', 'IOT', 'IO', 'io-t.gif', '0000-00-00 00:00:00', '2013-04-14 06:35:27', '0000-00-00 00:00:00', 1, '', ''),
(32, 1, 'Brunei Darussalam', 'BRN', 'BN', 'bn-t.gif', '0000-00-00 00:00:00', '2013-04-14 06:35:27', '0000-00-00 00:00:00', 1, '', ''),
(33, 1, 'Bulgaria', 'BGR', 'BG', 'bg-t.gif', '0000-00-00 00:00:00', '2013-04-14 06:35:27', '0000-00-00 00:00:00', 1, '', ''),
(34, 1, 'Burkina Faso', 'BFA', 'BF', 'bf-t.gif', '0000-00-00 00:00:00', '2013-04-14 06:35:27', '0000-00-00 00:00:00', 1, '', ''),
(35, 1, 'Burundi', 'BDI', 'BI', 'bi-t.gif', '0000-00-00 00:00:00', '2013-04-14 06:35:27', '0000-00-00 00:00:00', 1, '', ''),
(36, 1, 'Cambodia', 'KHM', 'KH', 'kh-t.gif', '0000-00-00 00:00:00', '2013-04-14 06:35:27', '0000-00-00 00:00:00', 1, '', ''),
(37, 1, 'Cameroon', 'CMR', 'CM', 'cm-t.gif', '0000-00-00 00:00:00', '2013-04-14 06:35:27', '0000-00-00 00:00:00', 1, '', ''),
(38, 1, 'Canada', 'CAN', 'CA', 'ca-t.gif', '0000-00-00 00:00:00', '2013-04-14 06:35:27', '0000-00-00 00:00:00', 1, '', ''),
(39, 1, 'Cape Verde', 'CPV', 'CV', 'cv-t.gif', '0000-00-00 00:00:00', '2013-04-14 06:35:27', '0000-00-00 00:00:00', 1, '', ''),
(40, 1, 'Cayman Islands', 'CYM', 'KY', 'ky-t.gif', '0000-00-00 00:00:00', '2013-04-14 06:35:27', '0000-00-00 00:00:00', 1, '', ''),
(41, 1, 'Central African Republic', 'CAF', 'CF', 'cf-t.gif', '0000-00-00 00:00:00', '2013-04-14 06:35:27', '0000-00-00 00:00:00', 1, '', ''),
(42, 1, 'Chad', 'TCD', 'TD', 'td-t.gif', '0000-00-00 00:00:00', '2013-04-14 06:35:27', '0000-00-00 00:00:00', 1, '', ''),
(43, 1, 'Chile', 'CHL', 'CL', 'cl-t.gif', '0000-00-00 00:00:00', '2013-04-14 06:35:27', '0000-00-00 00:00:00', 1, '', ''),
(44, 1, 'China', 'CHN', 'CN', 'cn-t.gif', '0000-00-00 00:00:00', '2013-04-14 06:35:27', '0000-00-00 00:00:00', 1, '', ''),
(45, 1, 'Christmas Island', 'CXR', 'CX', 'cx-t.gif', '0000-00-00 00:00:00', '2013-04-14 06:35:27', '0000-00-00 00:00:00', 1, '', ''),
(46, 1, 'Cocos (Keeling) Islands', 'CCK', 'CC', 'cc-t.gif', '0000-00-00 00:00:00', '2013-04-14 06:35:27', '0000-00-00 00:00:00', 1, '', ''),
(47, 1, 'Colombia', 'COL', 'CO', 'co-t.gif', '0000-00-00 00:00:00', '2013-04-14 06:35:27', '0000-00-00 00:00:00', 1, '', ''),
(48, 1, 'Comoros', 'COM', 'KM', 'km-t.gif', '0000-00-00 00:00:00', '2013-04-14 06:35:27', '0000-00-00 00:00:00', 1, '', ''),
(49, 1, 'Congo', 'COG', 'CG', 'cg-t.gif', '0000-00-00 00:00:00', '2013-04-14 06:35:27', '0000-00-00 00:00:00', 1, '', ''),
(50, 1, 'Cook Islands', 'COK', 'CK', 'ck-t.gif', '0000-00-00 00:00:00', '2013-04-14 06:35:27', '0000-00-00 00:00:00', 1, '', ''),
(51, 1, 'Costa Rica', 'CRI', 'CR', 'cr-t.gif', '0000-00-00 00:00:00', '2013-04-14 06:35:27', '0000-00-00 00:00:00', 1, '', ''),
(52, 1, 'Cote D''Ivoire', 'CIV', 'CI', 'ci-t.gif', '0000-00-00 00:00:00', '2013-04-14 06:35:27', '0000-00-00 00:00:00', 1, '', ''),
(53, 1, 'Croatia', 'HRV', 'HR', 'hr-t.gif', '0000-00-00 00:00:00', '2013-04-14 06:35:27', '0000-00-00 00:00:00', 1, '', ''),
(54, 1, 'Cuba', 'CUB', 'CU', 'cu-t.gif', '0000-00-00 00:00:00', '2013-04-14 06:35:27', '0000-00-00 00:00:00', 1, '', ''),
(55, 1, 'Cyprus', 'CYP', 'CY', 'cy-t.gif', '0000-00-00 00:00:00', '2013-04-14 06:35:27', '0000-00-00 00:00:00', 1, '', ''),
(56, 1, 'Czech Republic', 'CZE', 'CZ', 'cz-t.gif', '0000-00-00 00:00:00', '2013-04-14 06:35:27', '0000-00-00 00:00:00', 1, '', ''),
(57, 1, 'Denmark', 'DNK', 'DK', 'dk-t.gif', '0000-00-00 00:00:00', '2013-04-14 06:35:27', '0000-00-00 00:00:00', 1, '', ''),
(58, 1, 'Djibouti', 'DJI', 'DJ', 'dj-t.gif', '0000-00-00 00:00:00', '2013-04-14 06:35:27', '0000-00-00 00:00:00', 1, '', ''),
(59, 1, 'Dominica', 'DMA', 'DM', 'dm-t.gif', '0000-00-00 00:00:00', '2013-04-14 06:35:27', '0000-00-00 00:00:00', 1, '', ''),
(60, 1, 'Dominican Republic', 'DOM', 'DO', 'do-t.gif', '0000-00-00 00:00:00', '2013-04-14 06:35:27', '0000-00-00 00:00:00', 1, '', ''),
(61, 1, 'East Timor', 'TMP', 'TP', 'tp-t.gif', '0000-00-00 00:00:00', '2013-04-14 06:35:27', '0000-00-00 00:00:00', 1, '', ''),
(62, 1, 'Ecuador', 'ECU', 'EC', 'ec-t.gif', '0000-00-00 00:00:00', '2013-04-14 06:35:27', '0000-00-00 00:00:00', 1, '', ''),
(63, 1, 'Egypt', 'EGY', 'EG', 'eg-t.gif', '0000-00-00 00:00:00', '2013-04-14 06:35:27', '0000-00-00 00:00:00', 1, '', ''),
(64, 1, 'El Salvador', 'SLV', 'SV', 'sv-t.gif', '0000-00-00 00:00:00', '2013-04-14 06:35:27', '0000-00-00 00:00:00', 1, '', ''),
(65, 1, 'Equatorial Guinea', 'GNQ', 'GQ', 'gq-t.gif', '0000-00-00 00:00:00', '2013-04-14 06:35:27', '0000-00-00 00:00:00', 1, '', ''),
(66, 1, 'Eritrea', 'ERI', 'ER', 'er-t.gif', '0000-00-00 00:00:00', '2013-04-14 06:35:27', '0000-00-00 00:00:00', 1, '', ''),
(67, 1, 'Estonia', 'EST', 'EE', 'ee-t.gif', '0000-00-00 00:00:00', '2013-04-14 06:35:27', '0000-00-00 00:00:00', 1, '', ''),
(68, 1, 'Ethiopia', 'ETH', 'ET', 'et-t.gif', '0000-00-00 00:00:00', '2013-04-14 06:35:27', '0000-00-00 00:00:00', 1, '', ''),
(69, 1, 'Falkland Islands (Malvinas)', 'FLK', 'FK', 'fk-t.gif', '0000-00-00 00:00:00', '2013-04-14 06:35:27', '0000-00-00 00:00:00', 1, '', ''),
(70, 1, 'Faroe Islands', 'FRO', 'FO', 'fo-t.gif', '0000-00-00 00:00:00', '2013-04-14 06:35:27', '0000-00-00 00:00:00', 1, '', ''),
(71, 1, 'Fiji', 'FJI', 'FJ', 'fj-t.gif', '0000-00-00 00:00:00', '2013-04-14 06:35:27', '0000-00-00 00:00:00', 1, '', ''),
(72, 1, 'Finland', 'FIN', 'FI', 'fi-t.gif', '0000-00-00 00:00:00', '2013-04-14 06:35:27', '0000-00-00 00:00:00', 1, '', ''),
(73, 1, 'France', 'FRA', 'FR', 'fr-t.gif', '0000-00-00 00:00:00', '2013-04-14 06:35:27', '0000-00-00 00:00:00', 1, '', ''),
(74, 1, 'France, Metropolitan', 'FXX', 'FX', 'fx-t.gif', '0000-00-00 00:00:00', '2013-04-14 06:35:27', '0000-00-00 00:00:00', 1, '', ''),
(75, 1, 'French Guiana', 'GUF', 'GF', 'gf-t.gif', '0000-00-00 00:00:00', '2013-04-14 06:35:27', '0000-00-00 00:00:00', 1, '', ''),
(76, 1, 'French Polynesia', 'PYF', 'PF', 'pf-t.gif', '0000-00-00 00:00:00', '2013-04-14 06:35:27', '0000-00-00 00:00:00', 1, '', ''),
(77, 1, 'French Southern Territories', 'ATF', 'TF', 'tf-t.gif', '0000-00-00 00:00:00', '2013-04-14 06:35:27', '0000-00-00 00:00:00', 1, '', ''),
(78, 1, 'Gabon', 'GAB', 'GA', 'ga-t.gif', '0000-00-00 00:00:00', '2013-04-14 06:35:27', '0000-00-00 00:00:00', 1, '', ''),
(79, 1, 'Gambia', 'GMB', 'GM', 'gm-t.gif', '0000-00-00 00:00:00', '2013-04-14 06:35:27', '0000-00-00 00:00:00', 1, '', ''),
(80, 1, 'Georgia', 'GEO', 'GE', 'ge-t.gif', '0000-00-00 00:00:00', '2013-04-14 06:35:27', '0000-00-00 00:00:00', 1, '', ''),
(81, 1, 'Germany', 'DEU', 'DE', 'de-t.gif', '0000-00-00 00:00:00', '2013-04-14 06:35:27', '0000-00-00 00:00:00', 1, '', ''),
(82, 1, 'Ghana', 'GHA', 'GH', 'gh-t.gif', '0000-00-00 00:00:00', '2013-04-14 06:35:27', '0000-00-00 00:00:00', 1, '', ''),
(83, 1, 'Gibraltar', 'GIB', 'GI', 'gi-t.gif', '0000-00-00 00:00:00', '2013-04-14 06:35:27', '0000-00-00 00:00:00', 1, '', ''),
(84, 1, 'Greece', 'GRC', 'GR', 'gr-t.gif', '0000-00-00 00:00:00', '2013-04-14 06:35:27', '0000-00-00 00:00:00', 1, '', ''),
(85, 1, 'Greenland', 'GRL', 'GL', 'gl-t.gif', '0000-00-00 00:00:00', '2013-04-14 06:35:27', '0000-00-00 00:00:00', 1, '', ''),
(86, 1, 'Grenada', 'GRD', 'GD', 'gd-t.gif', '0000-00-00 00:00:00', '2013-04-14 06:35:27', '0000-00-00 00:00:00', 1, '', ''),
(87, 1, 'Guadeloupe', 'GLP', 'GP', 'gp-t.gif', '0000-00-00 00:00:00', '2013-04-14 06:35:27', '0000-00-00 00:00:00', 1, '', ''),
(88, 1, 'Guam', 'GUM', 'GU', 'gu-t.gif', '0000-00-00 00:00:00', '2013-04-14 06:35:27', '0000-00-00 00:00:00', 1, '', ''),
(89, 1, 'Guatemala', 'GTM', 'GT', 'gt-t.gif', '0000-00-00 00:00:00', '2013-04-14 06:35:27', '0000-00-00 00:00:00', 1, '', ''),
(90, 1, 'Guinea', 'GIN', 'GN', 'gn-t.gif', '0000-00-00 00:00:00', '2013-04-14 06:35:27', '0000-00-00 00:00:00', 1, '', ''),
(91, 1, 'Guinea-bissau', 'GNB', 'GW', 'gw-t.gif', '0000-00-00 00:00:00', '2013-04-14 06:35:27', '0000-00-00 00:00:00', 1, '', ''),
(92, 1, 'Guyana', 'GUY', 'GY', 'gy-t.gif', '0000-00-00 00:00:00', '2013-04-14 06:35:27', '0000-00-00 00:00:00', 1, '', ''),
(93, 1, 'Haiti', 'HTI', 'HT', 'ht-t.gif', '0000-00-00 00:00:00', '2013-04-14 06:35:27', '0000-00-00 00:00:00', 1, '', ''),
(94, 1, 'Heard and Mc Donald Islands', 'HMD', 'HM', 'hm-t.gif', '0000-00-00 00:00:00', '2013-04-14 06:35:27', '0000-00-00 00:00:00', 1, '', ''),
(95, 1, 'Honduras', 'HND', 'HN', 'hn-t.gif', '0000-00-00 00:00:00', '2013-04-14 06:35:27', '0000-00-00 00:00:00', 1, '', ''),
(96, 1, 'Hong Kong', 'HKG', 'HK', 'hk-t.gif', '0000-00-00 00:00:00', '2013-04-14 06:35:27', '0000-00-00 00:00:00', 1, '', ''),
(97, 1, 'Hungary', 'HUN', 'HU', 'hu-t.gif', '0000-00-00 00:00:00', '2013-04-14 06:35:27', '0000-00-00 00:00:00', 1, '', ''),
(98, 1, 'Iceland', 'ISL', 'IS', 'is-t.gif', '0000-00-00 00:00:00', '2013-04-14 06:35:27', '0000-00-00 00:00:00', 1, '', ''),
(99, 1, 'India', 'IND', 'IN', 'in-t.gif', '0000-00-00 00:00:00', '2013-04-14 06:35:27', '0000-00-00 00:00:00', 1, '', ''),
(100, 1, 'Indonesia', 'IDN', 'ID', 'id-t.gif', '0000-00-00 00:00:00', '2013-04-14 06:35:27', '0000-00-00 00:00:00', 1, '', ''),
(101, 1, 'Iran (Islamic Republic of)', 'IRN', 'IR', 'ir-t.gif', '0000-00-00 00:00:00', '2013-04-14 06:35:27', '0000-00-00 00:00:00', 1, '', ''),
(102, 1, 'Iraq', 'IRQ', 'IQ', 'iq-t.gif', '0000-00-00 00:00:00', '2013-04-14 06:35:27', '0000-00-00 00:00:00', 1, '', ''),
(103, 1, 'Ireland', 'IRL', 'IE', 'ie-t.gif', '0000-00-00 00:00:00', '2013-04-14 06:35:27', '0000-00-00 00:00:00', 1, '', ''),
(104, 1, 'Israel', 'ISR', 'IL', 'il-t.gif', '0000-00-00 00:00:00', '2013-04-14 06:35:27', '0000-00-00 00:00:00', 1, '', ''),
(105, 1, 'Italy', 'ITA', 'IT', 'it-t.gif', '0000-00-00 00:00:00', '2013-04-14 06:35:27', '0000-00-00 00:00:00', 1, '', ''),
(106, 1, 'Jamaica', 'JAM', 'JM', 'jm-t.gif', '0000-00-00 00:00:00', '2013-04-14 06:35:27', '0000-00-00 00:00:00', 1, '', ''),
(107, 1, 'Japan', 'JPN', 'JP', 'jp-t.gif', '0000-00-00 00:00:00', '2013-04-14 06:35:27', '0000-00-00 00:00:00', 1, '', ''),
(108, 1, 'Jordan', 'JOR', 'JO', 'jo-t.gif', '0000-00-00 00:00:00', '2013-04-14 06:35:27', '0000-00-00 00:00:00', 1, '', ''),
(109, 1, 'Kazakhstan', 'KAZ', 'KZ', 'kz-t.gif', '0000-00-00 00:00:00', '2013-04-14 06:35:27', '0000-00-00 00:00:00', 1, '', ''),
(110, 1, 'Kenya', 'KEN', 'KE', 'ke-t.gif', '0000-00-00 00:00:00', '2013-04-14 06:35:27', '0000-00-00 00:00:00', 1, '', ''),
(111, 1, 'Kiribati', 'KIR', 'KI', 'ki-t.gif', '0000-00-00 00:00:00', '2013-04-14 06:35:27', '0000-00-00 00:00:00', 1, '', ''),
(112, 1, 'Korea, Democratic People''s Republic of', 'PRK', 'KP', 'kp-t.gif', '0000-00-00 00:00:00', '2013-04-14 06:35:27', '0000-00-00 00:00:00', 1, '', ''),
(113, 1, 'Korea, Republic of', 'KOR', 'KR', 'kr-t.gif', '0000-00-00 00:00:00', '2013-04-14 06:35:27', '0000-00-00 00:00:00', 1, '', ''),
(114, 1, 'Kuwait', 'KWT', 'KW', 'kw-t.gif', '0000-00-00 00:00:00', '2013-04-14 06:35:27', '0000-00-00 00:00:00', 1, '', ''),
(115, 1, 'Kyrgyzstan', 'KGZ', 'KG', 'kg-t.gif', '0000-00-00 00:00:00', '2013-04-14 06:35:27', '0000-00-00 00:00:00', 1, '', ''),
(116, 1, 'Lao People''s Democratic Republic', 'LAO', 'LA', 'la-t.gif', '0000-00-00 00:00:00', '2013-04-14 06:35:27', '0000-00-00 00:00:00', 1, '', ''),
(117, 1, 'Latvia', 'LVA', 'LV', 'lv-t.gif', '0000-00-00 00:00:00', '2013-04-14 06:35:27', '0000-00-00 00:00:00', 1, '', ''),
(118, 1, 'Lebanon', 'LBN', 'LB', 'lb-t.gif', '0000-00-00 00:00:00', '2013-04-14 06:35:27', '0000-00-00 00:00:00', 1, '', ''),
(119, 1, 'Lesotho', 'LSO', 'LS', 'ls-t.gif', '0000-00-00 00:00:00', '2013-04-14 06:35:27', '0000-00-00 00:00:00', 1, '', ''),
(120, 1, 'Liberia', 'LBR', 'LR', 'lr-t.gif', '0000-00-00 00:00:00', '2013-04-14 06:35:27', '0000-00-00 00:00:00', 1, '', ''),
(121, 1, 'Libyan Arab Jamahiriya', 'LBY', 'LY', 'ly-t.gif', '0000-00-00 00:00:00', '2013-04-14 06:35:27', '0000-00-00 00:00:00', 1, '', ''),
(122, 1, 'Liechtenstein', 'LIE', 'LI', 'li-t.gif', '0000-00-00 00:00:00', '2013-04-14 06:35:27', '0000-00-00 00:00:00', 1, '', ''),
(123, 1, 'Lithuania', 'LTU', 'LT', 'lt-t.gif', '0000-00-00 00:00:00', '2013-04-14 06:35:27', '0000-00-00 00:00:00', 1, '', ''),
(124, 1, 'Luxembourg', 'LUX', 'LU', 'lu-t.gif', '0000-00-00 00:00:00', '2013-04-14 06:35:27', '0000-00-00 00:00:00', 1, '', ''),
(125, 1, 'Macau', 'MAC', 'MO', 'mo-t.gif', '0000-00-00 00:00:00', '2013-04-14 06:35:27', '0000-00-00 00:00:00', 1, '', ''),
(126, 1, 'Macedonia, The Former Yugoslav Republic of', 'MKD', 'MK', 'mk-t.gif', '0000-00-00 00:00:00', '2013-04-14 06:35:27', '0000-00-00 00:00:00', 1, '', ''),
(127, 1, 'Madagascar', 'MDG', 'MG', 'mg-t.gif', '0000-00-00 00:00:00', '2013-04-14 06:35:27', '0000-00-00 00:00:00', 1, '', ''),
(128, 1, 'Malawi', 'MWI', 'MW', 'mw-t.gif', '0000-00-00 00:00:00', '2013-04-14 06:35:27', '0000-00-00 00:00:00', 1, '', ''),
(129, 1, 'Malaysia', 'MYS', 'MY', 'my-t.gif', '0000-00-00 00:00:00', '2013-04-14 06:35:27', '0000-00-00 00:00:00', 1, '', ''),
(130, 1, 'Maldives', 'MDV', 'MV', 'mv-t.gif', '0000-00-00 00:00:00', '2013-04-14 06:35:27', '0000-00-00 00:00:00', 1, '', ''),
(131, 1, 'Mali', 'MLI', 'ML', 'ml-t.gif', '0000-00-00 00:00:00', '2013-04-14 06:35:27', '0000-00-00 00:00:00', 1, '', ''),
(132, 1, 'Malta', 'MLT', 'MT', 'mt-t.gif', '0000-00-00 00:00:00', '2013-04-14 06:35:27', '0000-00-00 00:00:00', 1, '', ''),
(133, 1, 'Marshall Islands', 'MHL', 'MH', 'mh-t.gif', '0000-00-00 00:00:00', '2013-04-14 06:35:27', '0000-00-00 00:00:00', 1, '', ''),
(134, 1, 'Martinique', 'MTQ', 'MQ', 'mq-t.gif', '0000-00-00 00:00:00', '2013-04-14 06:35:27', '0000-00-00 00:00:00', 1, '', ''),
(135, 1, 'Mauritania', 'MRT', 'MR', 'mr-t.gif', '0000-00-00 00:00:00', '2013-04-14 06:35:27', '0000-00-00 00:00:00', 1, '', ''),
(136, 1, 'Mauritius', 'MUS', 'MU', 'mu-t.gif', '0000-00-00 00:00:00', '2013-04-14 06:35:27', '0000-00-00 00:00:00', 1, '', ''),
(137, 1, 'Mayotte', 'MYT', 'YT', 'yt-t.gif', '0000-00-00 00:00:00', '2013-04-14 06:35:27', '0000-00-00 00:00:00', 1, '', ''),
(138, 1, 'Mexico', 'MEX', 'MX', 'mx-t.gif', '0000-00-00 00:00:00', '2013-04-14 06:35:27', '0000-00-00 00:00:00', 1, '', ''),
(139, 1, 'Micronesia, Federated States of', 'FSM', 'FM', 'fm-t.gif', '0000-00-00 00:00:00', '2013-04-14 06:35:27', '0000-00-00 00:00:00', 1, '', ''),
(140, 1, 'Moldova, Republic of', 'MDA', 'MD', 'md-t.gif', '0000-00-00 00:00:00', '2013-04-14 06:35:27', '0000-00-00 00:00:00', 1, '', ''),
(141, 1, 'Monaco', 'MCO', 'MC', 'mc-t.gif', '0000-00-00 00:00:00', '2013-04-14 06:35:27', '0000-00-00 00:00:00', 1, '', ''),
(142, 1, 'Mongolia', 'MNG', 'MN', 'mn-t.gif', '0000-00-00 00:00:00', '2013-04-14 06:35:27', '0000-00-00 00:00:00', 1, '', ''),
(143, 1, 'Montserrat', 'MSR', 'MS', 'ms-t.gif', '0000-00-00 00:00:00', '2013-04-14 06:35:27', '0000-00-00 00:00:00', 1, '', ''),
(144, 1, 'Morocco', 'MAR', 'MA', 'ma-t.gif', '0000-00-00 00:00:00', '2013-04-14 06:35:27', '0000-00-00 00:00:00', 1, '', ''),
(145, 1, 'Mozambique', 'MOZ', 'MZ', 'mz-t.gif', '0000-00-00 00:00:00', '2013-04-14 06:35:27', '0000-00-00 00:00:00', 1, '', ''),
(146, 1, 'Myanmar', 'MMR', 'MM', 'mm-t.gif', '0000-00-00 00:00:00', '2013-04-14 06:35:27', '0000-00-00 00:00:00', 1, '', ''),
(147, 1, 'Namibia', 'NAM', 'NA', 'na-t.gif', '0000-00-00 00:00:00', '2013-04-14 06:35:27', '0000-00-00 00:00:00', 1, '', ''),
(148, 1, 'Nauru', 'NRU', 'NR', 'nr-t.gif', '0000-00-00 00:00:00', '2013-04-14 06:35:27', '0000-00-00 00:00:00', 1, '', ''),
(149, 1, 'Nepal', 'NPL', 'NP', 'np-t.gif', '0000-00-00 00:00:00', '2013-04-14 06:35:27', '0000-00-00 00:00:00', 1, '', ''),
(150, 1, 'Netherlands', 'NLD', 'NL', 'nl-t.gif', '0000-00-00 00:00:00', '2013-04-14 06:35:27', '0000-00-00 00:00:00', 1, '', ''),
(151, 1, 'Netherlands Antilles', 'ANT', 'AN', 'an-t.gif', '0000-00-00 00:00:00', '2013-04-14 06:35:27', '0000-00-00 00:00:00', 1, '', ''),
(152, 1, 'New Caledonia', 'NCL', 'NC', 'nc-t.gif', '0000-00-00 00:00:00', '2013-04-14 06:35:27', '0000-00-00 00:00:00', 1, '', ''),
(153, 1, 'New Zealand', 'NZL', 'NZ', 'nz-t.gif', '0000-00-00 00:00:00', '2013-04-14 06:35:27', '0000-00-00 00:00:00', 1, '', ''),
(154, 1, 'Nicaragua', 'NIC', 'NI', 'ni-t.gif', '0000-00-00 00:00:00', '2013-04-14 06:35:27', '0000-00-00 00:00:00', 1, '', ''),
(155, 1, 'Niger', 'NER', 'NE', 'ne-t.gif', '0000-00-00 00:00:00', '2013-04-14 06:35:27', '0000-00-00 00:00:00', 1, '', ''),
(156, 1, 'Nigeria', 'NGA', 'NG', 'ng-t.gif', '0000-00-00 00:00:00', '2013-04-14 06:35:27', '0000-00-00 00:00:00', 1, '', ''),
(157, 1, 'Niue', 'NIU', 'NU', 'nu-t.gif', '0000-00-00 00:00:00', '2013-04-14 06:35:27', '0000-00-00 00:00:00', 1, '', ''),
(158, 1, 'Norfolk Island', 'NFK', 'NF', 'nf-t.gif', '0000-00-00 00:00:00', '2013-04-14 06:35:27', '0000-00-00 00:00:00', 1, '', ''),
(159, 1, 'Northern Mariana Islands', 'MNP', 'MP', 'mp-t.gif', '0000-00-00 00:00:00', '2013-04-14 06:35:27', '0000-00-00 00:00:00', 1, '', ''),
(160, 1, 'Norway', 'NOR', 'NO', 'no-t.gif', '0000-00-00 00:00:00', '2013-04-14 06:35:27', '0000-00-00 00:00:00', 1, '', ''),
(161, 1, 'Oman', 'OMN', 'OM', 'om-t.gif', '0000-00-00 00:00:00', '2013-04-14 06:35:27', '0000-00-00 00:00:00', 1, '', ''),
(162, 1, 'Pakistan', 'PAK', 'PK', 'pk-t.gif', '0000-00-00 00:00:00', '2013-04-14 06:35:27', '0000-00-00 00:00:00', 1, '', ''),
(163, 1, 'Palau', 'PLW', 'PW', 'pw-t.gif', '0000-00-00 00:00:00', '2013-04-14 06:35:27', '0000-00-00 00:00:00', 1, '', ''),
(164, 1, 'Panama', 'PAN', 'PA', 'pa-t.gif', '0000-00-00 00:00:00', '2013-04-14 06:35:27', '0000-00-00 00:00:00', 1, '', ''),
(165, 1, 'Papua New Guinea', 'PNG', 'PG', 'pg-t.gif', '0000-00-00 00:00:00', '2013-04-14 06:35:27', '0000-00-00 00:00:00', 1, '', ''),
(166, 1, 'Paraguay', 'PRY', 'PY', 'py-t.gif', '0000-00-00 00:00:00', '2013-04-14 06:35:27', '0000-00-00 00:00:00', 1, '', ''),
(167, 1, 'Peru', 'PER', 'PE', 'pe-t.gif', '0000-00-00 00:00:00', '2013-04-14 06:35:27', '0000-00-00 00:00:00', 1, '', ''),
(168, 1, 'Philippines', 'PHL', 'PH', 'ph-t.gif', '0000-00-00 00:00:00', '2013-04-14 06:35:27', '0000-00-00 00:00:00', 1, '', ''),
(169, 1, 'Pitcairn', 'PCN', 'PN', 'pn-t.gif', '0000-00-00 00:00:00', '2013-04-14 06:35:27', '0000-00-00 00:00:00', 1, '', ''),
(170, 1, 'Poland', 'POL', 'PL', 'pl-t.gif', '0000-00-00 00:00:00', '2013-04-14 06:35:27', '0000-00-00 00:00:00', 1, '', ''),
(171, 1, 'Portugal', 'PRT', 'PT', 'pt-t.gif', '0000-00-00 00:00:00', '2013-04-14 06:35:27', '0000-00-00 00:00:00', 1, '', ''),
(172, 1, 'Puerto Rico', 'PRI', 'PR', 'pr-t.gif', '0000-00-00 00:00:00', '2013-04-14 06:35:27', '0000-00-00 00:00:00', 1, '', ''),
(173, 1, 'Qatar', 'QAT', 'QA', 'qa-t.gif', '0000-00-00 00:00:00', '2013-04-14 06:35:27', '0000-00-00 00:00:00', 1, '', ''),
(174, 1, 'Reunion', 'REU', 'RE', 're-t.gif', '0000-00-00 00:00:00', '2013-04-14 06:35:27', '0000-00-00 00:00:00', 1, '', ''),
(175, 1, 'Romania', 'ROM', 'RO', 'ro-t.gif', '0000-00-00 00:00:00', '2013-04-14 06:35:27', '0000-00-00 00:00:00', 1, '', ''),
(176, 1, 'Russian Federation', 'RUS', 'RU', 'ru-t.gif', '0000-00-00 00:00:00', '2013-04-14 06:35:27', '0000-00-00 00:00:00', 1, '', ''),
(177, 1, 'Rwanda', 'RWA', 'RW', 'rw-t.gif', '0000-00-00 00:00:00', '2013-04-14 06:35:27', '0000-00-00 00:00:00', 1, '', ''),
(178, 1, 'Saint Kitts and Nevis', 'KNA', 'KN', 'kn-t.gif', '0000-00-00 00:00:00', '2013-04-14 06:35:27', '0000-00-00 00:00:00', 1, '', ''),
(179, 1, 'Saint Lucia', 'LCA', 'LC', 'lc-t.gif', '0000-00-00 00:00:00', '2013-04-14 06:35:27', '0000-00-00 00:00:00', 1, '', ''),
(180, 1, 'Saint Vincent and the Grenadines', 'VCT', 'VC', 'vc-t.gif', '0000-00-00 00:00:00', '2013-04-14 06:35:27', '0000-00-00 00:00:00', 1, '', ''),
(181, 1, 'Samoa', 'WSM', 'WS', 'ws-t.gif', '0000-00-00 00:00:00', '2013-04-14 06:35:27', '0000-00-00 00:00:00', 1, '', ''),
(182, 1, 'San Marino', 'SMR', 'SM', 'sm-t.gif', '0000-00-00 00:00:00', '2013-04-14 06:35:27', '0000-00-00 00:00:00', 1, '', ''),
(183, 1, 'Sao Tome and Principe', 'STP', 'ST', 'st-t.gif', '0000-00-00 00:00:00', '2013-04-14 06:35:27', '0000-00-00 00:00:00', 1, '', ''),
(184, 1, 'Saudi Arabia', 'SAU', 'SA', 'sa-t.gif', '0000-00-00 00:00:00', '2013-04-14 06:35:27', '0000-00-00 00:00:00', 1, '', ''),
(185, 1, 'Senegal', 'SEN', 'SN', 'sn-t.gif', '0000-00-00 00:00:00', '2013-04-14 06:35:27', '0000-00-00 00:00:00', 1, '', ''),
(186, 1, 'Seychelles', 'SYC', 'SC', 'sc-t.gif', '0000-00-00 00:00:00', '2013-04-14 06:35:27', '0000-00-00 00:00:00', 1, '', ''),
(187, 1, 'Sierra Leone', 'SLE', 'SL', 'sl-t.gif', '0000-00-00 00:00:00', '2013-04-14 06:35:27', '0000-00-00 00:00:00', 1, '', ''),
(188, 1, 'Singapore', 'SGP', 'SG', 'sg-t.gif', '0000-00-00 00:00:00', '2013-04-14 06:35:27', '0000-00-00 00:00:00', 1, '', ''),
(189, 1, 'Slovakia (Slovak Republic)', 'SVK', 'SK', 'sk-t.gif', '0000-00-00 00:00:00', '2013-04-14 06:35:27', '0000-00-00 00:00:00', 1, '', ''),
(190, 1, 'Slovenia', 'SVN', 'SI', 'si-t.gif', '0000-00-00 00:00:00', '2013-04-14 06:35:27', '0000-00-00 00:00:00', 1, '', ''),
(191, 1, 'Solomon Islands', 'SLB', 'SB', 'sb-t.gif', '0000-00-00 00:00:00', '2013-04-14 06:35:27', '0000-00-00 00:00:00', 1, '', ''),
(192, 1, 'Somalia', 'SOM', 'SO', 'so-t.gif', '0000-00-00 00:00:00', '2013-04-14 06:35:27', '0000-00-00 00:00:00', 1, '', ''),
(193, 1, 'South Africa', 'ZAF', 'ZA', 'za-t.gif', '0000-00-00 00:00:00', '2013-04-14 06:35:27', '0000-00-00 00:00:00', 1, '', ''),
(194, 1, 'South Georgia and the South Sandwich Islands', 'SGS', 'GS', 'gs-t.gif', '0000-00-00 00:00:00', '2013-04-14 06:35:27', '0000-00-00 00:00:00', 1, '', ''),
(195, 1, 'Spain', 'ESP', 'ES', 'es-t.gif', '0000-00-00 00:00:00', '2013-04-14 06:35:27', '0000-00-00 00:00:00', 1, '', ''),
(196, 1, 'Sri Lanka', 'LKA', 'LK', 'lk-t.gif', '0000-00-00 00:00:00', '2013-04-14 06:35:27', '0000-00-00 00:00:00', 1, '', ''),
(197, 1, 'St. Helena', 'SHN', 'SH', 'sh-t.gif', '0000-00-00 00:00:00', '2013-04-14 06:35:27', '0000-00-00 00:00:00', 1, '', ''),
(198, 1, 'St. Pierre and Miquelon', 'SPM', 'PM', 'pm-t.gif', '0000-00-00 00:00:00', '2013-04-14 06:35:27', '0000-00-00 00:00:00', 1, '', ''),
(199, 1, 'Sudan', 'SDN', 'SD', 'sd-t.gif', '0000-00-00 00:00:00', '2013-04-14 06:35:27', '0000-00-00 00:00:00', 1, '', ''),
(200, 1, 'Suriname', 'SUR', 'SR', 'sr-t.gif', '0000-00-00 00:00:00', '2013-04-14 06:35:27', '0000-00-00 00:00:00', 1, '', ''),
(201, 1, 'Svalbard and Jan Mayen Islands', 'SJM', 'SJ', 'sj-t.gif', '0000-00-00 00:00:00', '2013-04-14 06:35:27', '0000-00-00 00:00:00', 1, '', ''),
(202, 1, 'Swaziland', 'SWZ', 'SZ', 'sz-t.gif', '0000-00-00 00:00:00', '2013-04-14 06:35:27', '0000-00-00 00:00:00', 1, '', ''),
(203, 1, 'Sweden', 'SWE', 'SE', 'se-t.gif', '0000-00-00 00:00:00', '2013-04-14 06:35:27', '0000-00-00 00:00:00', 1, '', ''),
(204, 1, 'Switzerland', 'CHE', 'CH', 'ch-t.gif', '0000-00-00 00:00:00', '2013-04-14 06:35:27', '0000-00-00 00:00:00', 1, '', ''),
(205, 1, 'Syrian Arab Republic', 'SYR', 'SY', 'sy-t.gif', '0000-00-00 00:00:00', '2013-04-14 06:35:27', '0000-00-00 00:00:00', 1, '', ''),
(206, 1, 'Taiwan', 'TWN', 'TW', 'tw-t.gif', '0000-00-00 00:00:00', '2013-04-14 06:35:27', '0000-00-00 00:00:00', 1, '', ''),
(207, 1, 'Tajikistan', 'TJK', 'TJ', 'tj-t.gif', '0000-00-00 00:00:00', '2013-04-14 06:35:27', '0000-00-00 00:00:00', 1, '', ''),
(208, 1, 'Tanzania, United Republic of', 'TZA', 'TZ', 'tz-t.gif', '0000-00-00 00:00:00', '2013-04-14 06:35:27', '0000-00-00 00:00:00', 1, '', ''),
(209, 1, 'Thailand', 'THA', 'TH', 'th-t.gif', '0000-00-00 00:00:00', '2013-04-14 06:35:27', '0000-00-00 00:00:00', 1, '', ''),
(210, 1, 'Togo', 'TGO', 'TG', 'tg-t.gif', '0000-00-00 00:00:00', '2013-04-14 06:35:27', '0000-00-00 00:00:00', 1, '', ''),
(211, 1, 'Tokelau', 'TKL', 'TK', 'tk-t.gif', '0000-00-00 00:00:00', '2013-04-14 06:35:27', '0000-00-00 00:00:00', 1, '', ''),
(212, 1, 'Tonga', 'TON', 'TO', 'to-t.gif', '0000-00-00 00:00:00', '2013-04-14 06:35:27', '0000-00-00 00:00:00', 1, '', ''),
(213, 1, 'Trinidad and Tobago', 'TTO', 'TT', 'tt-t.gif', '0000-00-00 00:00:00', '2013-04-14 06:35:27', '0000-00-00 00:00:00', 1, '', ''),
(214, 1, 'Tunisia', 'TUN', 'TN', 'tn-t.gif', '0000-00-00 00:00:00', '2013-04-14 06:35:27', '0000-00-00 00:00:00', 1, '', ''),
(215, 1, 'Turkey', 'TUR', 'TR', 'tr-t.gif', '0000-00-00 00:00:00', '2013-04-14 06:35:27', '0000-00-00 00:00:00', 1, '', ''),
(216, 1, 'Turkmenistan', 'TKM', 'TM', 'tm-t.gif', '0000-00-00 00:00:00', '2013-04-14 06:35:27', '0000-00-00 00:00:00', 1, '', ''),
(217, 1, 'Turks and Caicos Islands', 'TCA', 'TC', 'tc-t.gif', '0000-00-00 00:00:00', '2013-04-14 06:35:27', '0000-00-00 00:00:00', 1, '', ''),
(218, 1, 'Tuvalu', 'TUV', 'TV', 'tv-t.gif', '0000-00-00 00:00:00', '2013-04-14 06:35:27', '0000-00-00 00:00:00', 1, '', ''),
(219, 1, 'Uganda', 'UGA', 'UG', 'ug-t.gif', '0000-00-00 00:00:00', '2013-04-14 06:35:27', '0000-00-00 00:00:00', 1, '', ''),
(220, 1, 'Ukraine', 'UKR', 'UA', 'ua-t.gif', '0000-00-00 00:00:00', '2013-04-14 06:35:27', '0000-00-00 00:00:00', 1, '', ''),
(221, 1, 'United Arab Emirates', 'ARE', 'AE', 'ae-t.gif', '0000-00-00 00:00:00', '2013-04-14 06:35:27', '0000-00-00 00:00:00', 1, '', ''),
(222, 1, 'United Kingdom', 'GBR', 'GB', 'gb-t.gif', '0000-00-00 00:00:00', '2013-04-14 06:35:27', '0000-00-00 00:00:00', 1, '', ''),
(223, 1, 'United States', 'USA', 'US', 'us-t.gif', '0000-00-00 00:00:00', '2013-04-14 06:35:27', '0000-00-00 00:00:00', 1, '', ''),
(224, 1, 'United States Minor Outlying Islands', 'UMI', 'UM', '', '0000-00-00 00:00:00', '2013-04-14 06:35:27', '0000-00-00 00:00:00', 1, '', ''),
(225, 1, 'Uruguay', 'URY', 'UY', 'uy-t.gif', '0000-00-00 00:00:00', '2013-04-14 06:35:27', '0000-00-00 00:00:00', 1, '', ''),
(226, 1, 'Uzbekistan', 'UZB', 'UZ', 'uz-t.gif', '0000-00-00 00:00:00', '2013-04-14 06:35:27', '0000-00-00 00:00:00', 1, '', ''),
(227, 1, 'Vanuatu', 'VUT', 'VU', 'vu-t.gif', '0000-00-00 00:00:00', '2013-04-14 06:35:27', '0000-00-00 00:00:00', 1, '', ''),
(228, 1, 'Vatican City State (Holy See)', 'VAT', 'VA', 'va-t.gif', '0000-00-00 00:00:00', '2013-04-14 06:35:27', '0000-00-00 00:00:00', 1, '', ''),
(229, 1, 'Venezuela', 'VEN', 'VE', 've-t.gif', '0000-00-00 00:00:00', '2013-04-14 06:35:27', '0000-00-00 00:00:00', 1, '', ''),
(230, 1, 'Viet Nam', 'VNM', 'VN', 'vn-t.gif', '0000-00-00 00:00:00', '2013-04-14 06:35:27', '0000-00-00 00:00:00', 1, '', ''),
(231, 1, 'Virgin Islands (British)', 'VGB', 'VG', 'vg-t.gif', '0000-00-00 00:00:00', '2013-04-14 06:35:27', '0000-00-00 00:00:00', 1, '', ''),
(232, 1, 'Virgin Islands (U.S.)', 'VIR', 'VI', 'vi-t.gif', '0000-00-00 00:00:00', '2013-04-14 06:35:27', '0000-00-00 00:00:00', 1, '', ''),
(233, 1, 'Wallis and Futuna Islands', 'WLF', 'WF', 'wf-t.gif', '0000-00-00 00:00:00', '2013-04-14 06:35:27', '0000-00-00 00:00:00', 1, '', ''),
(234, 1, 'Western Sahara', 'ESH', 'EH', 'eh-t.gif', '0000-00-00 00:00:00', '2013-04-14 06:35:27', '0000-00-00 00:00:00', 1, '', ''),
(235, 1, 'Yemen', 'YEM', 'YE', 'ye-t.gif', '0000-00-00 00:00:00', '2013-04-14 06:35:27', '0000-00-00 00:00:00', 1, '', ''),
(236, 1, 'Yugoslavia', 'YUG', 'YU', 'yu-t.gif', '0000-00-00 00:00:00', '2013-04-14 06:35:27', '0000-00-00 00:00:00', 1, '', ''),
(237, 1, 'Democratic Republic of Congo', 'DRC', 'DC', '', '0000-00-00 00:00:00', '2013-04-14 06:35:27', '0000-00-00 00:00:00', 1, '', ''),
(238, 1, 'Zambia', 'ZMB', 'ZM', 'zm-t.gif', '0000-00-00 00:00:00', '2013-04-14 06:35:27', '0000-00-00 00:00:00', 1, '', ''),
(239, 1, 'Zimbabwe', 'ZWE', 'ZW', 'zw-t.gif', '0000-00-00 00:00:00', '2013-04-14 06:35:27', '0000-00-00 00:00:00', 1, '', ''),
(241, 1, 'Unknown', NULL, NULL, 'unknown.gif', '0000-00-00 00:00:00', '2013-04-14 06:35:27', '0000-00-00 00:00:00', 1, '', '');

-- --------------------------------------------------------

--
-- Table structure for table `com_meta_data`
--

CREATE TABLE IF NOT EXISTS `com_meta_data` (
  `meta_id` int(11) NOT NULL DEFAULT '0',
  `meta_title` varchar(255) NOT NULL,
  `meta_description` varchar(255) NOT NULL,
  `meta_type` int(11) NOT NULL,
  `createddatetime` datetime NOT NULL DEFAULT '0000-00-00 00:00:00' COMMENT 'created date time for this record',
  `updateddatetime` timestamp NOT NULL DEFAULT '0000-00-00 00:00:00' ON UPDATE CURRENT_TIMESTAMP COMMENT 'record updated date time',
  `deleteddatetime` datetime NOT NULL DEFAULT '0000-00-00 00:00:00' COMMENT 'deleted date for this record',
  `statusid` int(11) NOT NULL DEFAULT '0' COMMENT 'status of this record and foreign key for recordsstate table',
  `createdby` varchar(255) NOT NULL DEFAULT '' COMMENT 'Record created user',
  `lastupdatedby` varchar(255) NOT NULL DEFAULT '' COMMENT 'Record updated user',
  KEY `FK_store_meta_data_1` (`statusid`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Table structure for table `social_album`
--

CREATE TABLE IF NOT EXISTS `social_album` (
  `album_id` int(11) NOT NULL AUTO_INCREMENT,
  `album_type_id` int(11) NOT NULL,
  `album_description` varchar(255) NOT NULL DEFAULT '',
  `access_specifiers` enum('public','private') NOT NULL DEFAULT 'public',
  `createddatetime` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  `updateddatetime` timestamp NOT NULL DEFAULT '0000-00-00 00:00:00',
  `deleteddatetime` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  `statusid` int(11) NOT NULL DEFAULT '0',
  `createdby` varchar(255) NOT NULL DEFAULT '',
  `lastupdatedby` varchar(255) NOT NULL DEFAULT '',
  PRIMARY KEY (`album_id`),
  KEY `FK_social_album_1` (`statusid`),
  KEY `FK_social_album_2` (`album_type_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 AUTO_INCREMENT=1 ;

-- --------------------------------------------------------

--
-- Table structure for table `social_album_files`
--

CREATE TABLE IF NOT EXISTS `social_album_files` (
  `file_id` int(11) NOT NULL AUTO_INCREMENT,
  `album_id` int(11) NOT NULL,
  `userid` int(11) NOT NULL,
  `file_title` varchar(255) NOT NULL DEFAULT '',
  `file_path` varchar(255) NOT NULL DEFAULT '',
  `file_access_specifiers` enum('public','private') NOT NULL DEFAULT 'public',
  `createddatetime` datetime NOT NULL,
  `updateddatetime` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `deleteddatetime` datetime NOT NULL,
  `statusid` int(11) NOT NULL,
  `createdby` varchar(255) NOT NULL,
  `lastupdatedby` varchar(255) NOT NULL,
  PRIMARY KEY (`file_id`),
  KEY `FK_social_photos_1` (`statusid`),
  KEY `FK_social_photos_2` (`userid`),
  KEY `FK_social_photos_3` (`album_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 AUTO_INCREMENT=1 ;

-- --------------------------------------------------------

--
-- Table structure for table `social_album_files_comments`
--

CREATE TABLE IF NOT EXISTS `social_album_files_comments` (
  `file_comments_id` int(11) NOT NULL AUTO_INCREMENT,
  `file_id` int(11) NOT NULL DEFAULT '0',
  `userid` int(11) NOT NULL DEFAULT '0',
  `comment_description` varchar(255) NOT NULL DEFAULT '',
  `createddatetime` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  `updateddatetime` timestamp NOT NULL DEFAULT '0000-00-00 00:00:00',
  `deleteddatetime` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  `statusid` int(11) NOT NULL DEFAULT '0',
  `createdby` varchar(255) NOT NULL DEFAULT '',
  `lastupdatedby` varchar(255) NOT NULL DEFAULT '',
  PRIMARY KEY (`file_comments_id`),
  KEY `FK_social_album_photos_comments_2` (`userid`),
  KEY `FK_social_album_photos_comments_3` (`statusid`),
  KEY `FK_social_album_photos_comments_1` (`file_id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=latin1 AUTO_INCREMENT=1 ;

-- --------------------------------------------------------

--
-- Table structure for table `social_album_types`
--

CREATE TABLE IF NOT EXISTS `social_album_types` (
  `album_type_id` int(11) NOT NULL AUTO_INCREMENT,
  `album_type_title` varchar(255) NOT NULL DEFAULT '',
  `createddatetime` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  `updateddatetime` timestamp NOT NULL DEFAULT '0000-00-00 00:00:00',
  `deleteddatetime` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  `statusid` int(11) NOT NULL DEFAULT '0',
  `createdby` varchar(255) NOT NULL DEFAULT '',
  `lastupdatedby` varchar(255) NOT NULL DEFAULT '',
  PRIMARY KEY (`album_type_id`),
  KEY `FK_social_album_types_1` (`statusid`)
) ENGINE=InnoDB  DEFAULT CHARSET=latin1 AUTO_INCREMENT=5 ;

--
-- Dumping data for table `social_album_types`
--

INSERT INTO `social_album_types` (`album_type_id`, `album_type_title`, `createddatetime`, `updateddatetime`, `deleteddatetime`, `statusid`, `createdby`, `lastupdatedby`) VALUES
(1, 'File Sharing', '0000-00-00 00:00:00', '0000-00-00 00:00:00', '0000-00-00 00:00:00', 1, '', ''),
(2, 'Photos', '0000-00-00 00:00:00', '0000-00-00 00:00:00', '0000-00-00 00:00:00', 1, '', ''),
(3, 'Music', '0000-00-00 00:00:00', '0000-00-00 00:00:00', '0000-00-00 00:00:00', 1, '', ''),
(4, 'Videos', '0000-00-00 00:00:00', '0000-00-00 00:00:00', '0000-00-00 00:00:00', 1, '', '');

-- --------------------------------------------------------

--
-- Table structure for table `social_blog_articles`
--

CREATE TABLE IF NOT EXISTS `social_blog_articles` (
  `blog_article_id` int(11) NOT NULL AUTO_INCREMENT,
  `blog_category_id` int(11) NOT NULL DEFAULT '0',
  `userid` int(11) NOT NULL,
  `article_title` varchar(25) NOT NULL DEFAULT '',
  `article_description` text NOT NULL,
  `access_specifiers` enum('public','private') NOT NULL DEFAULT 'public',
  `createddatetime` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  `updateddatetime` timestamp NOT NULL DEFAULT '0000-00-00 00:00:00',
  `deleteddatetime` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  `statusid` int(11) NOT NULL DEFAULT '0',
  `createdby` varchar(255) NOT NULL DEFAULT '',
  `lastupdatedby` varchar(255) NOT NULL DEFAULT '',
  PRIMARY KEY (`blog_article_id`),
  KEY `FK_social_blog_articles_1` (`blog_category_id`),
  KEY `FK_social_blog_articles_2` (`statusid`),
  KEY `FK_social_blog_articles_3` (`userid`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 AUTO_INCREMENT=1 ;

-- --------------------------------------------------------

--
-- Table structure for table `social_blog_articles_comments`
--

CREATE TABLE IF NOT EXISTS `social_blog_articles_comments` (
  `articles_comments_id` int(11) NOT NULL AUTO_INCREMENT,
  `blog_article_id` int(11) NOT NULL DEFAULT '0',
  `userid` int(11) NOT NULL DEFAULT '0',
  `articles_comment` varchar(255) NOT NULL DEFAULT '',
  `createddatetime` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  `updateddatetime` timestamp NOT NULL DEFAULT '0000-00-00 00:00:00',
  `deleteddatetime` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  `statusid` int(11) NOT NULL DEFAULT '0',
  `createdby` varchar(255) NOT NULL DEFAULT '',
  `lastupdatedby` varchar(255) NOT NULL DEFAULT '',
  PRIMARY KEY (`articles_comments_id`),
  KEY `FK_social_blog_articles_comments_1` (`blog_article_id`),
  KEY `FK_social_blog_articles_comments_2` (`userid`),
  KEY `FK_social_blog_articles_comments_3` (`statusid`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 AUTO_INCREMENT=1 ;

-- --------------------------------------------------------

--
-- Table structure for table `social_blog_categories`
--

CREATE TABLE IF NOT EXISTS `social_blog_categories` (
  `blog_category_id` int(11) NOT NULL AUTO_INCREMENT,
  `category_title` varchar(255) NOT NULL DEFAULT '',
  `createddatetime` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  `updateddatetime` timestamp NOT NULL DEFAULT '0000-00-00 00:00:00',
  `deleteddatetime` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  `statusid` int(11) NOT NULL DEFAULT '0',
  `createdby` varchar(255) NOT NULL DEFAULT '',
  `lastupdatedby` varchar(255) NOT NULL DEFAULT '',
  PRIMARY KEY (`blog_category_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 AUTO_INCREMENT=1 ;

-- --------------------------------------------------------

--
-- Table structure for table `social_events`
--

CREATE TABLE IF NOT EXISTS `social_events` (
  `event_id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `userid` int(11) NOT NULL,
  `event_title` varchar(255) NOT NULL,
  `event_startdate` datetime NOT NULL,
  `event_enddate` datetime NOT NULL,
  `event_location` varchar(255) NOT NULL,
  `event_address` varchar(255) NOT NULL,
  `event_details` varchar(10000) NOT NULL,
  `event_type` varchar(45) NOT NULL,
  `event_image` varchar(255) NOT NULL,
  `createddatetime` datetime NOT NULL,
  `updateddatetime` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `deleteddatetime` datetime NOT NULL,
  `statusid` int(11) NOT NULL,
  `createdby` varchar(255) NOT NULL,
  `lastupdatedby` varchar(255) NOT NULL,
  PRIMARY KEY (`event_id`),
  KEY `FK_social_events_1` (`statusid`),
  KEY `FK_social_events_2` (`userid`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 AUTO_INCREMENT=1 ;

-- --------------------------------------------------------

--
-- Table structure for table `social_groups`
--

CREATE TABLE IF NOT EXISTS `social_groups` (
  `group_id` int(11) NOT NULL AUTO_INCREMENT,
  `group_title` varchar(255) NOT NULL DEFAULT '',
  `group_description` text NOT NULL,
  `group_image` varchar(255) NOT NULL DEFAULT '',
  `access_specifiers` enum('public','private') NOT NULL DEFAULT 'public',
  `createddatetime` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  `updateddatetime` timestamp NOT NULL DEFAULT '0000-00-00 00:00:00',
  `deleteddatetime` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  `statusid` int(11) NOT NULL DEFAULT '0',
  `createdby` varchar(255) NOT NULL DEFAULT '',
  `lastupdatedby` varchar(255) NOT NULL DEFAULT '',
  PRIMARY KEY (`group_id`),
  KEY `FK_social_groups_1` (`statusid`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 AUTO_INCREMENT=1 ;

-- --------------------------------------------------------

--
-- Table structure for table `social_groups_comments`
--

CREATE TABLE IF NOT EXISTS `social_groups_comments` (
  `group_comment_id` int(11) NOT NULL AUTO_INCREMENT,
  `group_id` int(11) NOT NULL DEFAULT '0',
  `userid` int(11) NOT NULL DEFAULT '0',
  `group_comment` text NOT NULL,
  `createddatetime` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  `updateddatetime` timestamp NOT NULL DEFAULT '0000-00-00 00:00:00',
  `deleteddatetime` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  `statusid` int(11) NOT NULL DEFAULT '0',
  `createdby` varchar(255) NOT NULL DEFAULT '',
  `lastupdatedby` varchar(255) NOT NULL DEFAULT '',
  PRIMARY KEY (`group_comment_id`),
  KEY `FK_social_groups_comments_1` (`group_id`),
  KEY `FK_social_groups_comments_2` (`userid`),
  KEY `FK_social_groups_comments_3` (`statusid`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 AUTO_INCREMENT=1 ;

-- --------------------------------------------------------

--
-- Table structure for table `social_groups_posts`
--

CREATE TABLE IF NOT EXISTS `social_groups_posts` (
  `group_post_id` int(11) NOT NULL AUTO_INCREMENT,
  `group_id` int(11) NOT NULL DEFAULT '0',
  `userid` int(11) NOT NULL DEFAULT '0',
  `group_post` text NOT NULL,
  `createddatetime` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  `updateddatetime` timestamp NOT NULL DEFAULT '0000-00-00 00:00:00',
  `deleteddatetime` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  `statusid` int(11) NOT NULL DEFAULT '0',
  `createdby` varchar(255) NOT NULL DEFAULT '',
  `lastupdatedby` varchar(255) NOT NULL DEFAULT '',
  PRIMARY KEY (`group_post_id`),
  KEY `FK_social_groups_posts_1` (`group_id`),
  KEY `FK_social_groups_posts_2` (`userid`),
  KEY `FK_social_groups_posts_3` (`statusid`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 AUTO_INCREMENT=1 ;

-- --------------------------------------------------------

--
-- Table structure for table `social_groups_users`
--

CREATE TABLE IF NOT EXISTS `social_groups_users` (
  `group_user_id` int(11) NOT NULL AUTO_INCREMENT,
  `group_id` int(11) NOT NULL DEFAULT '0',
  `userid` int(11) NOT NULL DEFAULT '0',
  `createddatetime` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  `updateddatetime` timestamp NOT NULL DEFAULT '0000-00-00 00:00:00',
  `deleteddatetime` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  `statusid` int(11) NOT NULL DEFAULT '0',
  `createdby` varchar(255) NOT NULL DEFAULT '',
  `lastupdatedby` varchar(255) NOT NULL DEFAULT '',
  PRIMARY KEY (`group_user_id`),
  KEY `FK_social_groups_users_1` (`group_id`),
  KEY `FK_social_groups_users_2` (`userid`),
  KEY `FK_social_groups_users_3` (`statusid`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 AUTO_INCREMENT=1 ;

-- --------------------------------------------------------

--
-- Table structure for table `social_internal_messaging`
--

CREATE TABLE IF NOT EXISTS `social_internal_messaging` (
  `message_id` int(11) NOT NULL AUTO_INCREMENT,
  `userid` int(11) NOT NULL,
  `message_subject` varchar(255) NOT NULL DEFAULT '',
  `message_body_content` text NOT NULL,
  `createddatetime` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  `updateddatetime` timestamp NOT NULL DEFAULT '0000-00-00 00:00:00',
  `deleteddatetime` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  `statusid` int(11) NOT NULL DEFAULT '0',
  `createdby` varchar(255) NOT NULL DEFAULT '',
  `lastupdatedby` varchar(255) NOT NULL DEFAULT '',
  PRIMARY KEY (`message_id`),
  KEY `FK_social_internal_messaging_1` (`statusid`),
  KEY `FK_social_internal_messaging_2` (`userid`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 AUTO_INCREMENT=1 ;

-- --------------------------------------------------------

--
-- Table structure for table `social_internal_messaging_users`
--

CREATE TABLE IF NOT EXISTS `social_internal_messaging_users` (
  `internal_messaging_user_id` int(11) NOT NULL AUTO_INCREMENT,
  `message_id` int(11) NOT NULL DEFAULT '0',
  `user_id` int(11) NOT NULL DEFAULT '0',
  `createddatetime` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  `updateddatetime` timestamp NOT NULL DEFAULT '0000-00-00 00:00:00',
  `deleteddatetime` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  `statusid` int(11) NOT NULL DEFAULT '0',
  `createdby` varchar(255) NOT NULL DEFAULT '',
  `lastupdatedby` varchar(255) NOT NULL DEFAULT '',
  PRIMARY KEY (`internal_messaging_user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 AUTO_INCREMENT=1 ;

-- --------------------------------------------------------

--
-- Table structure for table `store_categories`
--

CREATE TABLE IF NOT EXISTS `store_categories` (
  `category_id` bigint(20) NOT NULL AUTO_INCREMENT,
  `parent_category_id` bigint(20) NOT NULL,
  `category_name` varchar(255) NOT NULL,
  `category_meta_title` varchar(255) NOT NULL,
  `category_meta_description` varchar(255) NOT NULL,
  `createddatetime` datetime NOT NULL DEFAULT '0000-00-00 00:00:00' COMMENT 'created date time for this record',
  `updateddatetime` timestamp NOT NULL DEFAULT '0000-00-00 00:00:00' ON UPDATE CURRENT_TIMESTAMP COMMENT 'record updated date time',
  `deleteddatetime` datetime NOT NULL DEFAULT '0000-00-00 00:00:00' COMMENT 'deleted date for this record',
  `statusid` int(11) NOT NULL DEFAULT '0' COMMENT 'status of this record and foreign key for recordsstate table',
  `createdby` varchar(255) NOT NULL DEFAULT '' COMMENT 'Record created user',
  `lastupdatedby` varchar(255) NOT NULL DEFAULT '' COMMENT 'Record updated user',
  PRIMARY KEY (`category_id`),
  KEY `FK_store_categories_1` (`statusid`)
) ENGINE=InnoDB  DEFAULT CHARSET=latin1 AUTO_INCREMENT=32 ;

--
-- Dumping data for table `store_categories`
--

INSERT INTO `store_categories` (`category_id`, `parent_category_id`, `category_name`, `category_meta_title`, `category_meta_description`, `createddatetime`, `updateddatetime`, `deleteddatetime`, `statusid`, `createdby`, `lastupdatedby`) VALUES
(1, 0, 'category 1', 'category one', 'category one', '0000-00-00 00:00:00', '2013-04-22 17:44:32', '0000-00-00 00:00:00', 1, '', ''),
(2, 0, 'category 2', 'category two', 'category two', '0000-00-00 00:00:00', '2013-04-22 17:44:32', '0000-00-00 00:00:00', 1, '', ''),
(3, 0, 'Category 3', 'Meta Title', 'Meta Description', '2013-04-16 17:06:01', '2013-04-22 17:44:32', '0000-00-00 00:00:00', 1, '', ''),
(4, 0, 'Category 4', 'Meta Title', 'Meta Description', '2013-04-16 17:09:38', '2013-04-22 17:44:32', '2013-04-16 21:45:38', 1, '', ''),
(5, 0, 'Category 5', 'Meta Title', 'Meta Description', '2013-04-16 17:11:47', '2013-04-22 17:44:32', '2013-04-16 21:44:57', 1, '', ''),
(6, 1, 'Category 6', 'Meta Title', 'Meta Description', '2013-04-16 17:13:27', '2013-04-22 17:44:32', '0000-00-00 00:00:00', 1, '', ''),
(7, 1, 'Category 7', 'Meta Title', 'Meta Description', '2013-04-16 17:17:00', '2013-04-22 17:44:32', '0000-00-00 00:00:00', 1, '', ''),
(8, 1, 'Category 8', 'Meta Title', 'Meta Description', '2013-04-16 17:18:37', '2013-04-22 17:44:32', '2013-04-16 21:38:45', 1, '', ''),
(9, 1, 'category 9', '', '', '2013-04-16 17:51:20', '2013-04-22 17:44:32', '0000-00-00 00:00:00', 1, '', ''),
(10, 1, 'category 10', '', '', '2013-04-16 17:51:58', '2013-04-22 17:44:32', '0000-00-00 00:00:00', 1, '', ''),
(11, 1, 'category 11', '', '', '2013-04-16 17:52:44', '2013-04-22 17:44:32', '2013-04-16 21:40:03', 1, '', ''),
(12, 1, 'category 12', '', '', '2013-04-16 17:54:24', '2013-04-22 17:44:32', '0000-00-00 00:00:00', 1, '', ''),
(13, 1, 'category 13', '', '', '2013-04-16 17:58:11', '2013-04-22 17:44:32', '0000-00-00 00:00:00', 1, '', ''),
(14, 1, 'category 14', '', '', '2013-04-16 17:58:47', '2013-04-22 17:44:32', '0000-00-00 00:00:00', 1, '', ''),
(15, 1, 'category 15', '', '', '2013-04-16 17:59:19', '2013-04-22 17:44:32', '2013-04-16 21:40:59', 1, '', ''),
(16, 1, 'category 16', '', '', '2013-04-16 22:17:24', '2013-04-20 16:11:27', '0000-00-00 00:00:00', 1, '', ''),
(17, 1, 'category 17', '', '', '2013-04-16 22:19:02', '2013-04-20 16:11:27', '0000-00-00 00:00:00', 1, '', ''),
(18, 1, 'category 18', '', '', '2013-04-16 22:20:17', '2013-04-20 16:11:27', '0000-00-00 00:00:00', 1, '', ''),
(19, 1, 'category 19', '', '', '2013-04-16 22:21:55', '2013-04-20 16:11:27', '0000-00-00 00:00:00', 1, '', ''),
(20, 1, 'category 20', '', '', '2013-04-16 22:23:01', '2013-04-20 16:11:27', '0000-00-00 00:00:00', 1, '', ''),
(21, 2, 'category 21', '', '', '2013-04-16 22:25:37', '2013-04-20 16:11:48', '0000-00-00 00:00:00', 1, '', ''),
(22, 2, 'category 22', '', '', '2013-04-16 22:27:50', '2013-04-20 16:11:48', '0000-00-00 00:00:00', 1, '', ''),
(23, 2, 'category 23', '', '', '2013-04-16 22:28:28', '2013-04-20 16:11:48', '0000-00-00 00:00:00', 1, '', ''),
(24, 2, 'category 24', 'a 11', 'a 111', '2013-04-16 22:52:47', '2013-04-20 16:11:48', '0000-00-00 00:00:00', 1, '', ''),
(25, 2, 'category 25', '', '', '2013-04-16 22:53:31', '2013-04-20 16:11:48', '0000-00-00 00:00:00', 1, '', ''),
(26, 2, 'category 26', '', '', '2013-04-16 22:56:46', '2013-04-20 16:11:48', '0000-00-00 00:00:00', 1, '', ''),
(27, 2, 'category 27', '', '', '2013-04-16 22:59:13', '2013-04-20 16:11:48', '0000-00-00 00:00:00', 1, '', ''),
(28, 0, 'category 28', 'Meta Title', 'Meta Description', '2013-04-22 23:09:38', '0000-00-00 00:00:00', '0000-00-00 00:00:00', 1, '', ''),
(29, 0, 'category 29', 'Meta Title', 'Meta Description', '2013-04-22 23:15:32', '0000-00-00 00:00:00', '0000-00-00 00:00:00', 1, '', ''),
(30, 0, 'category 30', 'Meta Title', 'Meta Description', '2013-04-22 23:16:31', '0000-00-00 00:00:00', '0000-00-00 00:00:00', 1, '', ''),
(31, 0, 'category 111', '', '', '2013-06-08 13:12:42', '0000-00-00 00:00:00', '0000-00-00 00:00:00', 1, '', '');

-- --------------------------------------------------------

--
-- Table structure for table `store_categories_images`
--

CREATE TABLE IF NOT EXISTS `store_categories_images` (
  `category_image_id` bigint(20) NOT NULL AUTO_INCREMENT,
  `category_id` bigint(20) NOT NULL DEFAULT '0',
  `category_image` varchar(255) NOT NULL,
  `category_image_title` varchar(255) NOT NULL,
  `createddatetime` datetime NOT NULL DEFAULT '0000-00-00 00:00:00' COMMENT 'created date time for this record',
  `updateddatetime` timestamp NOT NULL DEFAULT '0000-00-00 00:00:00' ON UPDATE CURRENT_TIMESTAMP COMMENT 'record updated date time',
  `deleteddatetime` datetime NOT NULL DEFAULT '0000-00-00 00:00:00' COMMENT 'deleted date for this record',
  `statusid` int(11) NOT NULL DEFAULT '0' COMMENT 'status of this record and foreign key for recordsstate table',
  `createdby` varchar(255) NOT NULL DEFAULT '' COMMENT 'Record created user',
  `lastupdatedby` varchar(255) NOT NULL DEFAULT '' COMMENT 'Record updated user',
  PRIMARY KEY (`category_image_id`),
  KEY `FK_store_categories_images_1` (`category_id`),
  KEY `FK_store_categories_images_2` (`statusid`)
) ENGINE=InnoDB  DEFAULT CHARSET=latin1 AUTO_INCREMENT=16 ;

--
-- Dumping data for table `store_categories_images`
--

INSERT INTO `store_categories_images` (`category_image_id`, `category_id`, `category_image`, `category_image_title`, `createddatetime`, `updateddatetime`, `deleteddatetime`, `statusid`, `createdby`, `lastupdatedby`) VALUES
(5, 30, '136665279116476_502081836505361_814867919_n.jpg', 'category 30', '2013-04-22 23:16:32', '2013-04-23 09:56:09', '0000-00-00 00:00:00', 3, '', ''),
(6, 30, '1366711725Penguins.jpg', 'category 30', '2013-04-23 15:38:46', '2013-04-23 10:57:28', '0000-00-00 00:00:00', 3, '', ''),
(7, 30, '1366712754Penguins.jpg', 'category 30', '2013-04-23 15:55:55', '2013-04-23 10:57:51', '0000-00-00 00:00:00', 3, '', ''),
(8, 30, '1366714686Tulips.jpg', 'category 30', '2013-04-23 16:28:07', '2013-04-23 11:01:40', '0000-00-00 00:00:00', 3, '', ''),
(9, 30, '1366714926Jellyfish.jpg', 'category 30', '2013-04-23 16:32:07', '2013-04-23 11:12:06', '0000-00-00 00:00:00', 3, '', ''),
(10, 30, '1366715559Desert.jpg', 'category 30', '2013-04-23 16:42:40', '2013-04-25 04:55:43', '0000-00-00 00:00:00', 3, '', ''),
(11, 30, '1366715800Desert.jpg', 'category 30', '2013-04-23 16:46:41', '2013-04-25 04:55:43', '0000-00-00 00:00:00', 3, '', ''),
(12, 30, '1366715844Desert.jpg', 'category 30', '2013-04-23 16:47:25', '2013-04-25 04:55:43', '0000-00-00 00:00:00', 3, '', ''),
(13, 30, '1366716041Desert.jpg', 'category 30', '2013-04-23 16:50:42', '2013-04-25 04:58:13', '0000-00-00 00:00:00', 3, '', ''),
(14, 30, '1366866435Hydrangeas.jpg', 'category 30', '2013-04-25 10:37:16', '2013-04-25 05:12:13', '0000-00-00 00:00:00', 3, '', ''),
(15, 30, '1366866753Chrysanthemum.jpg', 'category 30', '2013-04-25 10:42:34', '0000-00-00 00:00:00', '0000-00-00 00:00:00', 1, '', '');

-- --------------------------------------------------------

--
-- Table structure for table `store_merchants`
--

CREATE TABLE IF NOT EXISTS `store_merchants` (
  `merchant_id` int(11) NOT NULL AUTO_INCREMENT,
  `merchant_title` varchar(255) NOT NULL,
  `merchant_email` varchar(255) NOT NULL,
  `merchant_mobile` varchar(255) NOT NULL,
  `merchant_phone` varchar(255) NOT NULL,
  `merchant_fax` varchar(255) NOT NULL,
  `merchant_city` varchar(255) NOT NULL,
  `merchant_state` varchar(255) NOT NULL,
  `merchant_country` int(11) NOT NULL,
  `merchant_address1` varchar(5000) NOT NULL,
  `merchant_address2` varchar(5000) NOT NULL,
  `merchant_postcode` varchar(255) NOT NULL,
  `merchant_description` text NOT NULL,
  `createddatetime` datetime NOT NULL,
  `updateddatetime` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `deleteddatetime` datetime NOT NULL,
  `statusid` int(11) NOT NULL,
  `createdby` varchar(255) NOT NULL,
  `lastupdatedby` varchar(255) NOT NULL,
  PRIMARY KEY (`merchant_id`),
  KEY `FK_store_merchants_1` (`statusid`)
) ENGINE=InnoDB  DEFAULT CHARSET=latin1 AUTO_INCREMENT=26 ;

--
-- Dumping data for table `store_merchants`
--

INSERT INTO `store_merchants` (`merchant_id`, `merchant_title`, `merchant_email`, `merchant_mobile`, `merchant_phone`, `merchant_fax`, `merchant_city`, `merchant_state`, `merchant_country`, `merchant_address1`, `merchant_address2`, `merchant_postcode`, `merchant_description`, `createddatetime`, `updateddatetime`, `deleteddatetime`, `statusid`, `createdby`, `lastupdatedby`) VALUES
(1, 'Merchant One', 'merchant1@gmail.com', '9876543211', '9876543212', '', '', '', 99, '', '', '', 'Merchant One Description', '0000-00-00 00:00:00', '2013-04-20 10:50:49', '0000-00-00 00:00:00', 1, '', ''),
(2, 'Merchant Two', 'merchant2@gmail.com', '9876543211', '9876543212', '', '', '', 99, '', '', '', 'Merchant Two Description', '0000-00-00 00:00:00', '2013-04-20 10:50:49', '0000-00-00 00:00:00', 1, '', ''),
(3, 'Merchant Three', 'merchant3@gmail.com', '9876543211', '9876543212', '', '', '', 99, '', '', '', 'Merchant Three Description', '0000-00-00 00:00:00', '2013-04-20 10:50:49', '0000-00-00 00:00:00', 1, '', ''),
(4, 'Merchant Four', 'merchant4@gmail.com', '9876543211', '9876543212', '', '', '', 99, '', '', '', '', '2013-04-20 16:08:52', '2013-04-20 10:50:49', '0000-00-00 00:00:00', 1, '', ''),
(5, 'Merchant Five', 'merchant5@gmail.com', '9876543211', '9876543212', '', '', '', 99, '', '', '', '', '2013-04-20 16:14:46', '2013-04-20 10:50:49', '0000-00-00 00:00:00', 1, '', ''),
(6, 'Merchant Six', 'merchant6@gmail.com', '9876543211', '9876543212', '', '', '', 99, '', '', '', '', '2013-04-20 16:16:04', '2013-06-08 03:07:39', '2013-06-08 08:37:39', 3, '', ''),
(7, 'Merchant Seven', 'merchant7@gmail.com', '9876543211', '9876543212', '', '', '', 99, '', '', '', '', '2013-04-20 16:16:31', '2013-04-20 10:50:49', '0000-00-00 00:00:00', 1, '', ''),
(8, 'Merchant Eight', 'merchant8@gmail.com', '9876543211', '9876543212', '', '', '', 99, '', '', '', '', '0000-00-00 00:00:00', '2013-04-20 10:50:49', '0000-00-00 00:00:00', 1, '', ''),
(9, 'Merchant Nine', 'merchant9@gmail.com', '9876543211', '9876543212', '', '', '', 99, '', '', '', '', '0000-00-00 00:00:00', '2013-04-20 10:50:49', '0000-00-00 00:00:00', 1, '', ''),
(10, 'Merchant Ten', 'merchant10@gmail.com', '9876543211', '9876543212', '', '', '', 99, '', '', '', '', '0000-00-00 00:00:00', '2013-04-20 10:50:49', '0000-00-00 00:00:00', 1, '', ''),
(11, 'Merchant 11', 'merchant11@gmail.com', '9876543211', '9876543212', '9876543213', 'city', 'state', 99, 'address 1', 'address 2', '500016', 'description 111', '0000-00-00 00:00:00', '2013-04-20 15:43:55', '0000-00-00 00:00:00', 1, '', ''),
(12, 'Merchant 12', 'merchant12@gmail.com', '9876543211', '9876543212', '9876543213', '', '', 99, '', '', '', '', '0000-00-00 00:00:00', '2013-04-20 10:50:49', '0000-00-00 00:00:00', 1, '', ''),
(13, 'Merchant 13', 'Merchant13@gmail.com', '9876543211', '9876543212', '9876543213', 'city', 'state', 6, 'Address 11', 'Address 22', '500016', 'Description 12', '2013-04-20 21:15:19', '2013-04-20 15:45:19', '0000-00-00 00:00:00', 1, '', ''),
(14, 'Merchant 14', '', '', '', '', '', '', 0, '', '', '', '', '2013-04-25 12:50:39', '2013-04-25 07:20:39', '0000-00-00 00:00:00', 1, '', ''),
(15, 'Merchant 15', '', '', '', '', '', '', 0, '', '', '', '', '2013-04-25 14:07:25', '2013-04-25 08:37:25', '0000-00-00 00:00:00', 1, '', ''),
(16, 'Merchant 16', '', '', '', '', '', '', 0, '', '', '', '', '2013-04-25 14:40:00', '2013-04-25 09:10:00', '0000-00-00 00:00:00', 1, '', ''),
(17, 'Merchant 17', '', '', '', '', '', '', 0, '', '', '', '', '2013-04-25 14:41:55', '2013-04-25 09:11:55', '0000-00-00 00:00:00', 1, '', ''),
(18, 'Merchant 18', '', '', '', '', '', '', 0, '', '', '', '', '2013-04-25 14:42:48', '2013-04-25 09:12:48', '0000-00-00 00:00:00', 1, '', ''),
(19, 'Merchant 19', '', '', '', '', '', '', 0, '', '', '', '', '2013-04-25 14:44:33', '2013-04-25 09:14:33', '0000-00-00 00:00:00', 1, '', ''),
(20, 'Merchant 20', '', '', '', '', '', '', 0, '', '', '', '', '2013-04-25 14:45:51', '2013-04-25 09:15:51', '0000-00-00 00:00:00', 1, '', ''),
(21, 'Merchant 21', '', '', '', '', '', '', 0, '', '', '', '', '2013-04-25 14:48:27', '2013-04-25 09:18:27', '0000-00-00 00:00:00', 1, '', ''),
(22, 'Merchant 22', '', '', '', '', '', '', 0, '', '', '', '', '2013-04-25 14:51:53', '2013-04-25 09:21:53', '0000-00-00 00:00:00', 1, '', ''),
(23, 'Merchant 23', '', '', '', '', '', '', 0, '', '', '', '', '2013-04-25 14:54:15', '2013-04-25 09:24:15', '0000-00-00 00:00:00', 1, '', ''),
(24, 'Merchant 24', '', '', '', '', '', '', 0, '', '', '', '', '2013-04-25 14:55:56', '2013-04-25 09:25:56', '0000-00-00 00:00:00', 1, '', ''),
(25, 'Merchant 25', '', '', '', '', '', '', 0, '', '', '', '', '2013-04-25 14:57:24', '2013-04-25 10:03:27', '0000-00-00 00:00:00', 1, '', '');

-- --------------------------------------------------------

--
-- Table structure for table `store_merchants_images`
--

CREATE TABLE IF NOT EXISTS `store_merchants_images` (
  `merchant_image_id` bigint(20) NOT NULL AUTO_INCREMENT,
  `merchant_id` int(11) NOT NULL DEFAULT '0',
  `merchant_image` varchar(225) NOT NULL DEFAULT '',
  `merchant_image_title` varchar(225) NOT NULL DEFAULT '',
  `createddatetime` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  `updateddatetime` timestamp NOT NULL DEFAULT '0000-00-00 00:00:00',
  `deleteddatetime` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  `statusid` int(11) NOT NULL DEFAULT '0',
  `createdby` varchar(225) NOT NULL DEFAULT '',
  `lastupdatedby` varchar(225) NOT NULL DEFAULT '',
  PRIMARY KEY (`merchant_image_id`),
  KEY `FK_store_merchants_images_1` (`merchant_id`),
  KEY `FK_store_merchants_images_2` (`statusid`)
) ENGINE=InnoDB  DEFAULT CHARSET=latin1 AUTO_INCREMENT=5 ;

--
-- Dumping data for table `store_merchants_images`
--

INSERT INTO `store_merchants_images` (`merchant_image_id`, `merchant_id`, `merchant_image`, `merchant_image_title`, `createddatetime`, `updateddatetime`, `deleteddatetime`, `statusid`, `createdby`, `lastupdatedby`) VALUES
(2, 25, '1366882044Hydrangeas.jpg', 'Merchant 25', '2013-04-25 14:57:26', '0000-00-00 00:00:00', '0000-00-00 00:00:00', 3, '', ''),
(3, 11, '1366885868Penguins.jpg', 'Merchant 11', '2013-04-25 16:01:09', '0000-00-00 00:00:00', '0000-00-00 00:00:00', 3, '', ''),
(4, 11, '1366885903Tulips.jpg', 'Merchant 11', '2013-04-25 16:01:44', '0000-00-00 00:00:00', '0000-00-00 00:00:00', 1, '', '');

-- --------------------------------------------------------

--
-- Table structure for table `store_merchants_users`
--

CREATE TABLE IF NOT EXISTS `store_merchants_users` (
  `merchants_user_id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `merchant_id` int(11) NOT NULL,
  `userid` int(11) NOT NULL,
  `createddatetime` datetime NOT NULL,
  `updateddatetime` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `deleteddatetime` datetime NOT NULL,
  `statusid` int(11) NOT NULL,
  `createdby` varchar(255) NOT NULL,
  `lastupdatedby` varchar(255) NOT NULL,
  PRIMARY KEY (`merchants_user_id`),
  KEY `FK_store_merchants_users_1` (`merchant_id`),
  KEY `FK_store_merchants_users_2` (`userid`),
  KEY `FK_store_merchants_users_3` (`statusid`)
) ENGINE=InnoDB  DEFAULT CHARSET=latin1 AUTO_INCREMENT=3 ;

--
-- Dumping data for table `store_merchants_users`
--

INSERT INTO `store_merchants_users` (`merchants_user_id`, `merchant_id`, `userid`, `createddatetime`, `updateddatetime`, `deleteddatetime`, `statusid`, `createdby`, `lastupdatedby`) VALUES
(2, 1, 85, '2013-06-02 15:15:52', '2013-06-02 09:45:52', '0000-00-00 00:00:00', 1, '', '');

-- --------------------------------------------------------

--
-- Table structure for table `store_products`
--

CREATE TABLE IF NOT EXISTS `store_products` (
  `product_id` bigint(20) NOT NULL AUTO_INCREMENT,
  `attributes_group_id` int(11) NOT NULL,
  `product_sku` varchar(45) NOT NULL,
  `product_title` varchar(255) NOT NULL,
  `product_small_description` varchar(5000) NOT NULL,
  `product_meta_title` varchar(255) NOT NULL,
  `product_meta_description` varchar(255) NOT NULL,
  `createddatetime` datetime NOT NULL DEFAULT '0000-00-00 00:00:00' COMMENT 'created date time for this record',
  `updateddatetime` timestamp NOT NULL DEFAULT '0000-00-00 00:00:00' ON UPDATE CURRENT_TIMESTAMP COMMENT 'record updated date time',
  `deleteddatetime` datetime NOT NULL DEFAULT '0000-00-00 00:00:00' COMMENT 'deleted date for this record',
  `statusid` int(11) NOT NULL DEFAULT '0' COMMENT 'status of this record and foreign key for recordsstate table',
  `createdby` varchar(255) NOT NULL DEFAULT '' COMMENT 'Record created user',
  `lastupdatedby` varchar(255) NOT NULL DEFAULT '' COMMENT 'Record updated user',
  PRIMARY KEY (`product_id`),
  KEY `FK_store_products_1` (`statusid`),
  KEY `FK_store_products_2` (`attributes_group_id`)
) ENGINE=InnoDB  DEFAULT CHARSET=latin1 AUTO_INCREMENT=9 ;

--
-- Dumping data for table `store_products`
--

INSERT INTO `store_products` (`product_id`, `attributes_group_id`, `product_sku`, `product_title`, `product_small_description`, `product_meta_title`, `product_meta_description`, `createddatetime`, `updateddatetime`, `deleteddatetime`, `statusid`, `createdby`, `lastupdatedby`) VALUES
(6, 1, '2423423111', 'Product 111', 'Product Small Description111', 'Meta Title111', 'Meta Description111', '2013-05-01 16:13:06', '2013-06-08 03:10:58', '2013-06-08 08:40:58', 3, '', ''),
(7, 1, 'P7', 'Product 7', 'Product Small Description', 'Meta Title', 'Meta Description', '2013-06-08 08:43:49', '2013-06-08 16:33:50', '0000-00-00 00:00:00', 1, '', ''),
(8, 1, 'P8', 'Product 8', 'Product Small Description\r\nProduct Small Description', 'Meta Title', 'Meta Description\r\nMeta Description', '2013-06-08 22:06:22', '0000-00-00 00:00:00', '0000-00-00 00:00:00', 1, '', '');

-- --------------------------------------------------------

--
-- Table structure for table `store_products_attributes`
--

CREATE TABLE IF NOT EXISTS `store_products_attributes` (
  `attribute_id` int(11) NOT NULL AUTO_INCREMENT,
  `attribute_title` varchar(255) NOT NULL,
  `attribute_field_type` varchar(255) NOT NULL,
  `attribute_data_type` varchar(255) NOT NULL,
  `createddatetime` datetime NOT NULL DEFAULT '0000-00-00 00:00:00' COMMENT 'created date time for this record',
  `updateddatetime` timestamp NOT NULL DEFAULT '0000-00-00 00:00:00' ON UPDATE CURRENT_TIMESTAMP COMMENT 'record updated date time',
  `deleteddatetime` datetime NOT NULL DEFAULT '0000-00-00 00:00:00' COMMENT 'deleted date for this record',
  `statusid` int(11) NOT NULL DEFAULT '0' COMMENT 'status of this record and foreign key for recordsstate table',
  `createdby` varchar(255) NOT NULL DEFAULT '' COMMENT 'Record created user',
  `lastupdatedby` varchar(255) NOT NULL DEFAULT '' COMMENT 'Record updated user',
  PRIMARY KEY (`attribute_id`),
  KEY `FK_store_products_attributes_1` (`statusid`)
) ENGINE=InnoDB  DEFAULT CHARSET=latin1 AUTO_INCREMENT=12 ;

--
-- Dumping data for table `store_products_attributes`
--

INSERT INTO `store_products_attributes` (`attribute_id`, `attribute_title`, `attribute_field_type`, `attribute_data_type`, `createddatetime`, `updateddatetime`, `deleteddatetime`, `statusid`, `createdby`, `lastupdatedby`) VALUES
(1, 'Attribute One', 'text', 'VARCHAR', '2013-04-20 23:14:05', '0000-00-00 00:00:00', '0000-00-00 00:00:00', 1, '', ''),
(2, 'Attribute Two', 'text', 'VARCHAR', '2013-04-20 23:18:41', '0000-00-00 00:00:00', '0000-00-00 00:00:00', 1, '', ''),
(3, 'Attribute Three', 'text', 'VARCHAR', '2013-04-20 23:19:17', '0000-00-00 00:00:00', '0000-00-00 00:00:00', 1, '', ''),
(4, 'Attribute Four', 'textarea', 'DATE', '2013-04-20 23:20:18', '0000-00-00 00:00:00', '0000-00-00 00:00:00', 1, '', ''),
(5, 'Attribute Five', 'textarea', 'DATE', '2013-04-20 23:47:02', '2013-04-20 19:00:26', '0000-00-00 00:00:00', 1, '', ''),
(6, 'Attribute Six', 'textarea', 'DATE', '2013-04-20 23:49:36', '0000-00-00 00:00:00', '0000-00-00 00:00:00', 1, '', ''),
(7, 'Attribute Seven', 'textarea', 'VARCHAR', '2013-04-20 23:49:57', '0000-00-00 00:00:00', '0000-00-00 00:00:00', 1, '', ''),
(8, 'Attribute Eight', 'textarea', 'FLOAT', '2013-04-20 23:50:21', '2013-04-20 18:55:14', '0000-00-00 00:00:00', 6, '', ''),
(9, 'Attribute Nine', 'text', 'VARCHAR', '2013-04-20 23:50:41', '0000-00-00 00:00:00', '0000-00-00 00:00:00', 1, '', ''),
(10, 'Attribute Ten', 'text', 'INT', '2013-04-20 23:51:02', '0000-00-00 00:00:00', '0000-00-00 00:00:00', 1, '', ''),
(11, 'Attribute 11', 'textarea', 'FLOAT', '2013-04-20 23:51:29', '2013-04-21 16:19:44', '2013-04-21 00:30:41', 1, '', '');

-- --------------------------------------------------------

--
-- Table structure for table `store_products_attributes_groups`
--

CREATE TABLE IF NOT EXISTS `store_products_attributes_groups` (
  `attributes_group_id` int(11) NOT NULL AUTO_INCREMENT,
  `attributes_group_title` varchar(45) NOT NULL,
  `createddatetime` datetime NOT NULL,
  `updateddatetime` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `deleteddatetime` datetime NOT NULL,
  `statusid` int(11) NOT NULL,
  `createdby` varchar(255) NOT NULL,
  `lastupdatedby` varchar(255) NOT NULL,
  PRIMARY KEY (`attributes_group_id`),
  KEY `FK_store_products_attributes_groups_1` (`statusid`)
) ENGINE=InnoDB  DEFAULT CHARSET=latin1 AUTO_INCREMENT=4 ;

--
-- Dumping data for table `store_products_attributes_groups`
--

INSERT INTO `store_products_attributes_groups` (`attributes_group_id`, `attributes_group_title`, `createddatetime`, `updateddatetime`, `deleteddatetime`, `statusid`, `createdby`, `lastupdatedby`) VALUES
(1, 'Camera Specifications', '2013-04-28 11:13:57', '2013-04-28 07:53:49', '2013-04-28 13:00:57', 1, '', ''),
(2, 'Mobile Specifications', '2013-04-28 11:13:57', '2013-04-28 07:31:49', '2013-04-28 13:01:07', 1, '', ''),
(3, 'TV Specifications', '2013-04-28 11:17:09', '2013-04-28 07:31:37', '0000-00-00 00:00:00', 1, '', '');

-- --------------------------------------------------------

--
-- Table structure for table `store_products_attributes_sets`
--

CREATE TABLE IF NOT EXISTS `store_products_attributes_sets` (
  `attributes_set_id` int(11) NOT NULL AUTO_INCREMENT,
  `attributes_set_title` varchar(45) NOT NULL,
  `attributes_group_id` int(11) NOT NULL,
  `createddatetime` datetime NOT NULL,
  `updateddatetime` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `deleteddatetime` datetime NOT NULL,
  `statusid` int(11) NOT NULL,
  `createdby` varchar(255) NOT NULL,
  `lastupdatedby` varchar(255) NOT NULL,
  PRIMARY KEY (`attributes_set_id`),
  KEY `FK_store_products_attributes_sets_1` (`statusid`),
  KEY `FK_store_products_attributes_sets_2` (`attributes_group_id`)
) ENGINE=InnoDB  DEFAULT CHARSET=latin1 AUTO_INCREMENT=10 ;

--
-- Dumping data for table `store_products_attributes_sets`
--

INSERT INTO `store_products_attributes_sets` (`attributes_set_id`, `attributes_set_title`, `attributes_group_id`, `createddatetime`, `updateddatetime`, `deleteddatetime`, `statusid`, `createdby`, `lastupdatedby`) VALUES
(1, 'AttributeSet One', 1, '0000-00-00 00:00:00', '2013-04-28 05:15:14', '2013-04-21 22:57:03', 3, '', ''),
(2, 'AttributeSet 1', 1, '0000-00-00 00:00:00', '2013-04-30 06:02:10', '0000-00-00 00:00:00', 1, '', ''),
(3, 'AttributeSet 3', 1, '0000-00-00 00:00:00', '2013-04-30 06:02:32', '0000-00-00 00:00:00', 1, '', ''),
(4, 'AttributeSet 2', 1, '0000-00-00 00:00:00', '2013-04-30 06:01:48', '0000-00-00 00:00:00', 1, '', ''),
(5, 'test one', 2, '2013-04-22 20:48:13', '2013-04-30 06:00:37', '0000-00-00 00:00:00', 1, '', ''),
(6, 'test two', 2, '2013-04-22 20:54:44', '2013-04-30 05:59:47', '0000-00-00 00:00:00', 1, '', ''),
(7, 'test three', 2, '2013-04-22 20:55:47', '2013-04-30 06:00:14', '0000-00-00 00:00:00', 1, '', ''),
(8, 'test four', 2, '2013-04-22 20:58:24', '2013-04-30 05:57:04', '0000-00-00 00:00:00', 1, '', ''),
(9, 'General Info', 2, '2013-04-28 14:22:20', '2013-04-28 09:13:08', '0000-00-00 00:00:00', 1, '', '');

-- --------------------------------------------------------

--
-- Table structure for table `store_products_attributes_sets_mapping`
--

CREATE TABLE IF NOT EXISTS `store_products_attributes_sets_mapping` (
  `attributes_sets_mapping_id` int(11) NOT NULL AUTO_INCREMENT,
  `attribute_id` int(11) NOT NULL,
  `attributes_set_id` int(11) NOT NULL,
  `createddatetime` datetime NOT NULL,
  `updateddatetime` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `deleteddatetime` datetime NOT NULL,
  `statusid` int(11) NOT NULL,
  `createdby` varchar(255) NOT NULL,
  `lastupdatedby` varchar(255) NOT NULL,
  PRIMARY KEY (`attributes_sets_mapping_id`),
  KEY `FK_store_products_attributes_sets_mapping_1` (`attribute_id`),
  KEY `FK_store_products_attributes_sets_mapping_2` (`attributes_set_id`),
  KEY `FK_store_products_attributes_sets_mapping_3` (`statusid`)
) ENGINE=InnoDB  DEFAULT CHARSET=latin1 AUTO_INCREMENT=357 ;

--
-- Dumping data for table `store_products_attributes_sets_mapping`
--

INSERT INTO `store_products_attributes_sets_mapping` (`attributes_sets_mapping_id`, `attribute_id`, `attributes_set_id`, `createddatetime`, `updateddatetime`, `deleteddatetime`, `statusid`, `createdby`, `lastupdatedby`) VALUES
(348, 10, 3, '2013-05-27 15:34:46', '2013-05-27 10:04:46', '0000-00-00 00:00:00', 1, '', ''),
(349, 3, 3, '2013-05-27 15:34:46', '2013-05-27 10:04:46', '0000-00-00 00:00:00', 1, '', ''),
(350, 11, 3, '2013-05-27 15:34:46', '2013-05-27 10:04:46', '0000-00-00 00:00:00', 1, '', ''),
(351, 6, 4, '2013-05-27 15:34:46', '2013-05-27 10:04:46', '0000-00-00 00:00:00', 1, '', ''),
(352, 7, 4, '2013-05-27 15:34:46', '2013-05-27 10:04:46', '0000-00-00 00:00:00', 1, '', ''),
(353, 2, 4, '2013-05-27 15:34:46', '2013-05-27 10:04:46', '0000-00-00 00:00:00', 1, '', ''),
(354, 9, 2, '2013-05-27 15:34:46', '2013-05-27 10:04:46', '0000-00-00 00:00:00', 1, '', ''),
(355, 4, 2, '2013-05-27 15:34:46', '2013-05-27 10:04:46', '0000-00-00 00:00:00', 1, '', ''),
(356, 1, 2, '2013-05-27 15:34:46', '2013-05-27 10:04:46', '0000-00-00 00:00:00', 1, '', '');

-- --------------------------------------------------------

--
-- Table structure for table `store_products_attributes_values`
--

CREATE TABLE IF NOT EXISTS `store_products_attributes_values` (
  `attribute_value_id` bigint(20) NOT NULL AUTO_INCREMENT,
  `attribute_id` int(11) NOT NULL DEFAULT '0',
  `attribute_value` varchar(255) NOT NULL,
  `product_id` bigint(20) NOT NULL,
  `createddatetime` datetime NOT NULL DEFAULT '0000-00-00 00:00:00' COMMENT 'created date time for this record',
  `updateddatetime` timestamp NOT NULL DEFAULT '0000-00-00 00:00:00' ON UPDATE CURRENT_TIMESTAMP COMMENT 'record updated date time',
  `deleteddatetime` datetime NOT NULL DEFAULT '0000-00-00 00:00:00' COMMENT 'deleted date for this record',
  `statusid` int(11) NOT NULL DEFAULT '0' COMMENT 'status of this record and foreign key for recordsstate table',
  `createdby` varchar(255) NOT NULL DEFAULT '' COMMENT 'Record created user',
  `lastupdatedby` varchar(255) NOT NULL DEFAULT '' COMMENT 'Record updated user',
  PRIMARY KEY (`attribute_value_id`),
  KEY `FK_store_products_attributes_values_1` (`attribute_id`),
  KEY `FK_store_products_attributes_values_2` (`product_id`),
  KEY `FK_store_products_attributes_values_3` (`statusid`)
) ENGINE=InnoDB  DEFAULT CHARSET=latin1 AUTO_INCREMENT=15 ;

--
-- Dumping data for table `store_products_attributes_values`
--

INSERT INTO `store_products_attributes_values` (`attribute_value_id`, `attribute_id`, `attribute_value`, `product_id`, `createddatetime`, `updateddatetime`, `deleteddatetime`, `statusid`, `createdby`, `lastupdatedby`) VALUES
(1, 3, 'Attribute Three', 6, '2013-05-27 12:44:08', '0000-00-00 00:00:00', '0000-00-00 00:00:00', 1, '', ''),
(2, 10, 'Attribute Ten', 6, '2013-05-27 12:44:08', '0000-00-00 00:00:00', '0000-00-00 00:00:00', 1, '', ''),
(3, 2, 'Attribute Two ', 6, '2013-05-27 12:44:08', '0000-00-00 00:00:00', '0000-00-00 00:00:00', 1, '', ''),
(4, 6, 'Attribute Six ', 6, '2013-05-27 12:44:08', '0000-00-00 00:00:00', '0000-00-00 00:00:00', 1, '', ''),
(5, 7, 'Attribute Seven', 6, '2013-05-27 12:44:08', '0000-00-00 00:00:00', '0000-00-00 00:00:00', 1, '', ''),
(6, 1, 'Attribute One 11', 6, '2013-05-27 12:44:08', '2013-05-27 09:22:08', '0000-00-00 00:00:00', 1, '', ''),
(7, 9, 'Attribute Nine 11', 6, '2013-05-27 12:44:08', '2013-05-27 09:22:08', '0000-00-00 00:00:00', 1, '', ''),
(8, 4, 'Attribute Four 11', 6, '2013-05-27 12:44:08', '2013-05-27 09:22:08', '0000-00-00 00:00:00', 1, '', ''),
(9, 11, '', 6, '2013-05-27 14:58:43', '2013-05-27 09:29:45', '0000-00-00 00:00:00', 1, '', ''),
(10, 10, 'Ten', 8, '2013-06-08 22:13:23', '0000-00-00 00:00:00', '0000-00-00 00:00:00', 1, '', ''),
(11, 6, 'Six', 8, '2013-06-08 22:13:23', '0000-00-00 00:00:00', '0000-00-00 00:00:00', 1, '', ''),
(12, 7, 'Seven', 8, '2013-06-08 22:13:23', '0000-00-00 00:00:00', '0000-00-00 00:00:00', 1, '', ''),
(13, 1, 'One', 8, '2013-06-08 22:13:23', '0000-00-00 00:00:00', '0000-00-00 00:00:00', 1, '', ''),
(14, 4, 'Four', 8, '2013-06-08 22:13:23', '0000-00-00 00:00:00', '0000-00-00 00:00:00', 1, '', '');

-- --------------------------------------------------------

--
-- Table structure for table `store_products_categories`
--

CREATE TABLE IF NOT EXISTS `store_products_categories` (
  `product_category_id` bigint(20) NOT NULL AUTO_INCREMENT,
  `product_id` bigint(20) NOT NULL,
  `category_id` bigint(20) NOT NULL,
  `createddatetime` datetime NOT NULL DEFAULT '0000-00-00 00:00:00' COMMENT 'created date time for this record',
  `updateddatetime` timestamp NOT NULL DEFAULT '0000-00-00 00:00:00' ON UPDATE CURRENT_TIMESTAMP COMMENT 'record updated date time',
  `deleteddatetime` datetime NOT NULL DEFAULT '0000-00-00 00:00:00' COMMENT 'deleted date for this record',
  `statusid` int(11) NOT NULL DEFAULT '0' COMMENT 'status of this record and foreign key for recordsstate table',
  `createdby` varchar(255) NOT NULL DEFAULT '' COMMENT 'Record created user',
  `lastupdatedby` varchar(255) NOT NULL DEFAULT '' COMMENT 'Record updated user',
  PRIMARY KEY (`product_category_id`),
  KEY `FK_store_products_categories_1` (`product_id`),
  KEY `FK_store_products_categories_2` (`category_id`),
  KEY `FK_store_products_categories_3` (`statusid`)
) ENGINE=InnoDB  DEFAULT CHARSET=latin1 AUTO_INCREMENT=90 ;

--
-- Dumping data for table `store_products_categories`
--

INSERT INTO `store_products_categories` (`product_category_id`, `product_id`, `category_id`, `createddatetime`, `updateddatetime`, `deleteddatetime`, `statusid`, `createdby`, `lastupdatedby`) VALUES
(65, 6, 29, '2013-05-22 17:23:33', '0000-00-00 00:00:00', '0000-00-00 00:00:00', 1, '', ''),
(66, 6, 5, '2013-05-22 17:23:33', '0000-00-00 00:00:00', '0000-00-00 00:00:00', 1, '', ''),
(67, 6, 3, '2013-05-22 17:23:33', '0000-00-00 00:00:00', '0000-00-00 00:00:00', 1, '', ''),
(68, 6, 27, '2013-05-22 17:23:33', '0000-00-00 00:00:00', '0000-00-00 00:00:00', 1, '', ''),
(69, 6, 25, '2013-05-22 17:23:33', '0000-00-00 00:00:00', '0000-00-00 00:00:00', 1, '', ''),
(70, 6, 23, '2013-05-22 17:23:33', '0000-00-00 00:00:00', '0000-00-00 00:00:00', 1, '', ''),
(71, 6, 21, '2013-05-22 17:23:33', '0000-00-00 00:00:00', '0000-00-00 00:00:00', 1, '', ''),
(72, 6, 2, '2013-05-22 17:23:33', '0000-00-00 00:00:00', '0000-00-00 00:00:00', 1, '', ''),
(73, 6, 20, '2013-05-22 17:23:33', '0000-00-00 00:00:00', '0000-00-00 00:00:00', 1, '', ''),
(74, 6, 18, '2013-05-22 17:23:33', '0000-00-00 00:00:00', '0000-00-00 00:00:00', 1, '', ''),
(75, 6, 16, '2013-05-22 17:23:33', '0000-00-00 00:00:00', '0000-00-00 00:00:00', 1, '', ''),
(76, 6, 14, '2013-05-22 17:23:33', '0000-00-00 00:00:00', '0000-00-00 00:00:00', 1, '', ''),
(77, 6, 12, '2013-05-22 17:23:33', '0000-00-00 00:00:00', '0000-00-00 00:00:00', 1, '', ''),
(78, 6, 10, '2013-05-22 17:23:33', '0000-00-00 00:00:00', '0000-00-00 00:00:00', 1, '', ''),
(79, 6, 8, '2013-05-22 17:23:33', '0000-00-00 00:00:00', '0000-00-00 00:00:00', 1, '', ''),
(80, 6, 6, '2013-05-22 17:23:33', '0000-00-00 00:00:00', '0000-00-00 00:00:00', 1, '', ''),
(81, 6, 1, '2013-05-22 17:23:33', '0000-00-00 00:00:00', '0000-00-00 00:00:00', 1, '', ''),
(84, 7, 8, '2013-06-08 16:51:01', '0000-00-00 00:00:00', '0000-00-00 00:00:00', 1, '', ''),
(85, 7, 6, '2013-06-08 16:51:01', '0000-00-00 00:00:00', '0000-00-00 00:00:00', 1, '', ''),
(86, 8, 5, '2013-06-08 22:12:02', '0000-00-00 00:00:00', '0000-00-00 00:00:00', 1, '', ''),
(87, 8, 9, '2013-06-08 22:12:02', '0000-00-00 00:00:00', '0000-00-00 00:00:00', 1, '', ''),
(88, 8, 7, '2013-06-08 22:12:02', '0000-00-00 00:00:00', '0000-00-00 00:00:00', 1, '', ''),
(89, 8, 1, '2013-06-08 22:12:02', '0000-00-00 00:00:00', '0000-00-00 00:00:00', 1, '', '');

-- --------------------------------------------------------

--
-- Table structure for table `store_products_description`
--

CREATE TABLE IF NOT EXISTS `store_products_description` (
  `description_id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `product_description` text NOT NULL,
  `product_id` bigint(20) NOT NULL DEFAULT '0',
  `createddatetime` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  `updateddatetime` timestamp NOT NULL DEFAULT '0000-00-00 00:00:00',
  `deleteddatetime` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  `statusid` int(11) NOT NULL DEFAULT '0',
  `createdby` varchar(45) NOT NULL DEFAULT '',
  `lastupdatedby` varchar(45) NOT NULL DEFAULT '',
  PRIMARY KEY (`description_id`),
  KEY `FK_store_products_description_1` (`product_id`),
  KEY `FK_store_products_description_2` (`statusid`)
) ENGINE=InnoDB  DEFAULT CHARSET=latin1 AUTO_INCREMENT=4 ;

--
-- Dumping data for table `store_products_description`
--

INSERT INTO `store_products_description` (`description_id`, `product_description`, `product_id`, `createddatetime`, `updateddatetime`, `deleteddatetime`, `statusid`, `createdby`, `lastupdatedby`) VALUES
(1, 'ggdfg111', 6, '2013-05-01 16:13:06', '0000-00-00 00:00:00', '0000-00-00 00:00:00', 1, '', ''),
(2, 'Product Large Decription', 7, '2013-06-08 08:43:49', '0000-00-00 00:00:00', '0000-00-00 00:00:00', 1, '', ''),
(3, 'Product Large Description', 8, '2013-06-08 22:06:22', '0000-00-00 00:00:00', '0000-00-00 00:00:00', 1, '', '');

-- --------------------------------------------------------

--
-- Table structure for table `store_products_images`
--

CREATE TABLE IF NOT EXISTS `store_products_images` (
  `product_image_id` bigint(20) NOT NULL AUTO_INCREMENT,
  `product_id` bigint(20) NOT NULL DEFAULT '0',
  `product_image` varchar(255) NOT NULL DEFAULT '',
  `product_image_title` varchar(255) NOT NULL DEFAULT '',
  `home_page_image` int(11) NOT NULL DEFAULT '0',
  `product_thumbnail` int(11) NOT NULL DEFAULT '0',
  `createddatetime` datetime NOT NULL DEFAULT '0000-00-00 00:00:00' COMMENT 'created date time for this record',
  `updateddatetime` timestamp NOT NULL DEFAULT '0000-00-00 00:00:00' ON UPDATE CURRENT_TIMESTAMP COMMENT 'record updated date time',
  `deleteddatetime` datetime NOT NULL DEFAULT '0000-00-00 00:00:00' COMMENT 'deleted date for this record',
  `statusid` int(11) NOT NULL DEFAULT '0' COMMENT 'status of this record and foreign key for recordsstate table',
  `createdby` varchar(255) NOT NULL DEFAULT '' COMMENT 'Record created user',
  `lastupdatedby` varchar(255) NOT NULL DEFAULT '' COMMENT 'Record updated user',
  PRIMARY KEY (`product_image_id`),
  KEY `FK_store_products_images_1` (`product_id`),
  KEY `FK_store_products_images_2` (`statusid`)
) ENGINE=InnoDB  DEFAULT CHARSET=latin1 AUTO_INCREMENT=24 ;

-- --------------------------------------------------------

--
-- Table structure for table `store_products_price`
--

CREATE TABLE IF NOT EXISTS `store_products_price` (
  `product_price_id` bigint(20) NOT NULL AUTO_INCREMENT,
  `discount_start_date` date NOT NULL,
  `discount_end_date` date NOT NULL,
  `product_id` bigint(20) NOT NULL,
  `product_price_description` varchar(255) NOT NULL,
  `product_price` float NOT NULL,
  `product_discount` float NOT NULL,
  `product_discount_type` enum('Percentage','Amount') NOT NULL DEFAULT 'Percentage',
  `product_stock` int(11) NOT NULL,
  `createddatetime` datetime NOT NULL DEFAULT '0000-00-00 00:00:00' COMMENT 'created date time for this record',
  `updateddatetime` timestamp NOT NULL DEFAULT '0000-00-00 00:00:00' ON UPDATE CURRENT_TIMESTAMP COMMENT 'record updated date time',
  `deleteddatetime` datetime NOT NULL DEFAULT '0000-00-00 00:00:00' COMMENT 'deleted date for this record',
  `statusid` int(11) NOT NULL DEFAULT '0' COMMENT 'status of this record and foreign key for recordsstate table',
  `createdby` varchar(255) NOT NULL DEFAULT '' COMMENT 'Record created user',
  `lastupdatedby` varchar(255) NOT NULL DEFAULT '' COMMENT 'Record updated user',
  PRIMARY KEY (`product_price_id`),
  KEY `FK_store_products_price_1` (`product_id`),
  KEY `FK_store_products_price_2` (`statusid`)
) ENGINE=InnoDB  DEFAULT CHARSET=latin1 AUTO_INCREMENT=8 ;

--
-- Dumping data for table `store_products_price`
--

INSERT INTO `store_products_price` (`product_price_id`, `discount_start_date`, `discount_end_date`, `product_id`, `product_price_description`, `product_price`, `product_discount`, `product_discount_type`, `product_stock`, `createddatetime`, `updateddatetime`, `deleteddatetime`, `statusid`, `createdby`, `lastupdatedby`) VALUES
(1, '2013-06-01', '2013-06-30', 6, 'product_price_description 11', 1.111, 11, 'Percentage', 1, '2013-05-21 01:06:11', '2013-06-06 17:07:57', '0000-00-00 00:00:00', 1, '', ''),
(2, '2013-06-01', '2013-06-30', 6, 'product_price_description 22', 2.222, 22, 'Amount', 2, '2013-05-21 01:05:16', '2013-06-06 17:07:57', '0000-00-00 00:00:00', 1, '', ''),
(3, '2013-06-01', '2013-06-30', 8, 'XXL', 55, 5, 'Amount', 555, '2013-06-08 22:09:24', '0000-00-00 00:00:00', '0000-00-00 00:00:00', 1, '', ''),
(4, '2013-06-01', '2013-06-30', 8, 'XL', 44, 4, 'Percentage', 444, '2013-06-08 22:09:24', '0000-00-00 00:00:00', '0000-00-00 00:00:00', 1, '', ''),
(5, '2013-06-01', '2013-06-30', 8, 'L', 33, 3, 'Percentage', 333, '2013-06-08 22:09:24', '0000-00-00 00:00:00', '0000-00-00 00:00:00', 1, '', ''),
(6, '2013-06-01', '2013-06-30', 8, 'M', 22, 2, 'Percentage', 222, '2013-06-08 22:09:24', '0000-00-00 00:00:00', '0000-00-00 00:00:00', 1, '', ''),
(7, '2013-06-01', '2013-06-30', 8, 'S', 11, 1, 'Percentage', 111, '2013-06-08 22:09:24', '0000-00-00 00:00:00', '0000-00-00 00:00:00', 1, '', '');

-- --------------------------------------------------------

--
-- Table structure for table `store_products_reviews`
--

CREATE TABLE IF NOT EXISTS `store_products_reviews` (
  `products_review_id` bigint(20) NOT NULL AUTO_INCREMENT,
  `review_title` varchar(255) NOT NULL,
  `review_description` text NOT NULL,
  `product_id` bigint(20) NOT NULL,
  `createddatetime` datetime NOT NULL DEFAULT '0000-00-00 00:00:00' COMMENT 'created date time for this record',
  `updateddatetime` timestamp NOT NULL DEFAULT '0000-00-00 00:00:00' ON UPDATE CURRENT_TIMESTAMP COMMENT 'record updated date time',
  `deleteddatetime` datetime NOT NULL DEFAULT '0000-00-00 00:00:00' COMMENT 'deleted date for this record',
  `statusid` int(11) NOT NULL DEFAULT '0' COMMENT 'status of this record and foreign key for recordsstate table',
  `createdby` varchar(255) NOT NULL DEFAULT '' COMMENT 'Record created user',
  `lastupdatedby` varchar(255) NOT NULL DEFAULT '' COMMENT 'Record updated user',
  PRIMARY KEY (`products_review_id`),
  KEY `FK_store_products_reviews_1` (`product_id`),
  KEY `FK_store_products_reviews_2` (`statusid`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 AUTO_INCREMENT=1 ;

-- --------------------------------------------------------

--
-- Table structure for table `store_users_invoices`
--

CREATE TABLE IF NOT EXISTS `store_users_invoices` (
  `invoice_id` bigint(20) NOT NULL AUTO_INCREMENT,
  `userid` int(11) NOT NULL DEFAULT '0',
  `invoices_shipping_status_id` int(11) NOT NULL DEFAULT '0',
  `invoices_payment_status_id` int(11) NOT NULL DEFAULT '0',
  `createddatetime` datetime NOT NULL DEFAULT '0000-00-00 00:00:00' COMMENT 'created date time for this record',
  `updateddatetime` timestamp NOT NULL DEFAULT '0000-00-00 00:00:00' ON UPDATE CURRENT_TIMESTAMP COMMENT 'record updated date time',
  `deleteddatetime` datetime NOT NULL DEFAULT '0000-00-00 00:00:00' COMMENT 'deleted date for this record',
  `statusid` int(11) NOT NULL DEFAULT '0' COMMENT 'status of this record and foreign key for recordsstate table',
  `createdby` varchar(255) NOT NULL DEFAULT '' COMMENT 'Record created user',
  `lastupdatedby` varchar(255) NOT NULL DEFAULT '' COMMENT 'Record updated user',
  PRIMARY KEY (`invoice_id`),
  KEY `FK_store_users_invoices_1` (`invoices_shipping_status_id`),
  KEY `FK_store_users_invoices_2` (`invoices_payment_status_id`),
  KEY `FK_store_users_invoices_3` (`statusid`),
  KEY `FK_store_users_invoices_4` (`userid`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 AUTO_INCREMENT=1 ;

-- --------------------------------------------------------

--
-- Table structure for table `store_users_invoices_billing_and_shipping_details`
--

CREATE TABLE IF NOT EXISTS `store_users_invoices_billing_and_shipping_details` (
  `invoices_shipping_details_id` bigint(20) NOT NULL AUTO_INCREMENT,
  `invoice_id` bigint(20) NOT NULL,
  `contact_person_title` varchar(25) NOT NULL,
  `contact_person_first_name` varchar(255) NOT NULL,
  `contact_person_last_name` varchar(255) NOT NULL,
  `contact_person_middle_name` varchar(255) NOT NULL,
  `address_one` varchar(255) NOT NULL,
  `address_two` varchar(255) NOT NULL,
  `city` varchar(255) NOT NULL,
  `state` varchar(255) NOT NULL,
  `country_id` int(11) NOT NULL DEFAULT '0',
  `mobile_number` varchar(15) NOT NULL DEFAULT '',
  `phone_number` varchar(15) NOT NULL,
  `fax_number` varchar(15) NOT NULL,
  `zipcode` varchar(15) NOT NULL,
  `email_address` varchar(255) NOT NULL,
  `details_type` enum('shipping','billing') NOT NULL DEFAULT 'billing',
  `createddatetime` datetime NOT NULL DEFAULT '0000-00-00 00:00:00' COMMENT 'created date time for this record',
  `updateddatetime` timestamp NOT NULL DEFAULT '0000-00-00 00:00:00' ON UPDATE CURRENT_TIMESTAMP COMMENT 'record updated date time',
  `deleteddatetime` datetime NOT NULL DEFAULT '0000-00-00 00:00:00' COMMENT 'deleted date for this record',
  `statusid` int(11) NOT NULL DEFAULT '0' COMMENT 'status of this record and foreign key for recordsstate table',
  `createdby` varchar(255) NOT NULL DEFAULT '' COMMENT 'Record created user',
  `lastupdatedby` varchar(255) NOT NULL DEFAULT '' COMMENT 'Record updated user',
  PRIMARY KEY (`invoices_shipping_details_id`),
  KEY `FK_store_users_invoices_billing_and_shipping_details_1` (`invoice_id`),
  KEY `FK_store_users_invoices_billing_and_shipping_details_2` (`statusid`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 AUTO_INCREMENT=1 ;

-- --------------------------------------------------------

--
-- Table structure for table `store_users_invoices_details`
--

CREATE TABLE IF NOT EXISTS `store_users_invoices_details` (
  `invoice_details_id` bigint(20) NOT NULL AUTO_INCREMENT,
  `invoice_id` bigint(20) NOT NULL,
  `product_id` bigint(20) NOT NULL,
  `product_amount` float NOT NULL,
  `product_quantity` int(11) NOT NULL,
  `product_discount` float NOT NULL,
  `product_discount_type` enum('percentage','amount') NOT NULL DEFAULT 'percentage',
  `createddatetime` datetime NOT NULL DEFAULT '0000-00-00 00:00:00' COMMENT 'created date time for this record',
  `updateddatetime` timestamp NOT NULL DEFAULT '0000-00-00 00:00:00' ON UPDATE CURRENT_TIMESTAMP COMMENT 'record updated date time',
  `deleteddatetime` datetime NOT NULL DEFAULT '0000-00-00 00:00:00' COMMENT 'deleted date for this record',
  `statusid` int(11) NOT NULL DEFAULT '0' COMMENT 'status of this record and foreign key for recordsstate table',
  `createdby` varchar(255) NOT NULL DEFAULT '' COMMENT 'Record created user',
  `lastupdatedby` varchar(255) NOT NULL DEFAULT '' COMMENT 'Record updated user',
  PRIMARY KEY (`invoice_details_id`),
  KEY `FK_store_users_invoices_details_1` (`product_id`),
  KEY `FK_store_users_invoices_details_2` (`invoice_id`),
  KEY `FK_store_users_invoices_details_3` (`statusid`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 AUTO_INCREMENT=1 ;

-- --------------------------------------------------------

--
-- Table structure for table `store_users_invoices_master_payment_status`
--

CREATE TABLE IF NOT EXISTS `store_users_invoices_master_payment_status` (
  `invoices_payment_status_id` int(11) NOT NULL AUTO_INCREMENT,
  `status_title` varchar(255) NOT NULL,
  `createddatetime` datetime NOT NULL DEFAULT '0000-00-00 00:00:00' COMMENT 'created date time for this record',
  `updateddatetime` timestamp NOT NULL DEFAULT '0000-00-00 00:00:00' ON UPDATE CURRENT_TIMESTAMP COMMENT 'record updated date time',
  `deleteddatetime` datetime NOT NULL DEFAULT '0000-00-00 00:00:00' COMMENT 'deleted date for this record',
  `statusid` int(11) NOT NULL DEFAULT '0' COMMENT 'status of this record and foreign key for recordsstate table',
  `createdby` varchar(255) NOT NULL DEFAULT '' COMMENT 'Record created user',
  `lastupdatedby` varchar(255) NOT NULL DEFAULT '' COMMENT 'Record updated user',
  PRIMARY KEY (`invoices_payment_status_id`),
  KEY `FK_store_users_invoices_master_payment_status_1` (`statusid`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 AUTO_INCREMENT=1 ;

-- --------------------------------------------------------

--
-- Table structure for table `store_users_invoices_master_shipping_status`
--

CREATE TABLE IF NOT EXISTS `store_users_invoices_master_shipping_status` (
  `invoices_shipping_status_id` int(11) NOT NULL AUTO_INCREMENT,
  `status_title` varchar(255) NOT NULL,
  `createddatetime` datetime NOT NULL DEFAULT '0000-00-00 00:00:00' COMMENT 'created date time for this record',
  `updateddatetime` timestamp NOT NULL DEFAULT '0000-00-00 00:00:00' ON UPDATE CURRENT_TIMESTAMP COMMENT 'record updated date time',
  `deleteddatetime` datetime NOT NULL DEFAULT '0000-00-00 00:00:00' COMMENT 'deleted date for this record',
  `statusid` int(11) NOT NULL DEFAULT '0' COMMENT 'status of this record and foreign key for recordsstate table',
  `createdby` varchar(255) NOT NULL DEFAULT '' COMMENT 'Record created user',
  `lastupdatedby` varchar(255) NOT NULL DEFAULT '' COMMENT 'Record updated user',
  PRIMARY KEY (`invoices_shipping_status_id`),
  KEY `FK_store_users_invoices_master_shipping_status_1` (`statusid`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 AUTO_INCREMENT=1 ;

-- --------------------------------------------------------

--
-- Table structure for table `store_users_temp_cart`
--

CREATE TABLE IF NOT EXISTS `store_users_temp_cart` (
  `temp_cart_id` bigint(20) NOT NULL AUTO_INCREMENT,
  `userid` int(11) NOT NULL DEFAULT '0',
  `product_id` bigint(20) NOT NULL DEFAULT '0',
  `product_quantity` int(11) NOT NULL,
  `createddatetime` datetime NOT NULL DEFAULT '0000-00-00 00:00:00' COMMENT 'created date time for this record',
  `updateddatetime` timestamp NOT NULL DEFAULT '0000-00-00 00:00:00' ON UPDATE CURRENT_TIMESTAMP COMMENT 'record updated date time',
  `deleteddatetime` datetime NOT NULL DEFAULT '0000-00-00 00:00:00' COMMENT 'deleted date for this record',
  `statusid` int(11) NOT NULL DEFAULT '0' COMMENT 'status of this record and foreign key for recordsstate table',
  `createdby` varchar(255) NOT NULL DEFAULT '' COMMENT 'Record created user',
  `lastupdatedby` varchar(255) NOT NULL DEFAULT '' COMMENT 'Record updated user',
  PRIMARY KEY (`temp_cart_id`),
  KEY `FK_store_users_temp_cart_1` (`product_id`),
  KEY `FK_store_users_temp_cart_2` (`statusid`),
  KEY `FK_store_users_temp_cart_3` (`userid`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 AUTO_INCREMENT=1 ;

-- --------------------------------------------------------

--
-- Table structure for table `user_address`
--

CREATE TABLE IF NOT EXISTS `user_address` (
  `user_address_id` int(11) NOT NULL AUTO_INCREMENT,
  `userid` int(11) NOT NULL,
  `address_type` enum('Home','Office') NOT NULL DEFAULT 'Home',
  `address1` varchar(255) NOT NULL,
  `address2` varchar(255) NOT NULL,
  `city` varchar(255) NOT NULL,
  `street` varchar(255) NOT NULL,
  `postal_code` varchar(255) NOT NULL,
  `country_id` int(11) NOT NULL,
  `state_id` int(11) NOT NULL,
  `createddatetime` datetime NOT NULL,
  `updateddatetime` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `deleteddatetime` datetime NOT NULL,
  `statusid` int(11) NOT NULL,
  `createdby` varchar(255) NOT NULL,
  `lastupdatedby` varchar(255) NOT NULL,
  PRIMARY KEY (`user_address_id`),
  KEY `FK_user_address_1` (`userid`),
  KEY `FK_user_address_2` (`statusid`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 AUTO_INCREMENT=1 ;

-- --------------------------------------------------------

--
-- Table structure for table `user_connections`
--

CREATE TABLE IF NOT EXISTS `user_connections` (
  `connection_id` int(10) NOT NULL AUTO_INCREMENT,
  `userid` int(11) NOT NULL,
  `friend_id` int(11) NOT NULL,
  `request_status` int(11) NOT NULL DEFAULT '1' COMMENT '1=>Request Sent; 2=> Accepted; 3=> Rejected',
  `createddatetime` datetime NOT NULL,
  `updateddatetime` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `deleteddatetime` datetime NOT NULL,
  `statusid` int(11) NOT NULL,
  `createdby` varchar(255) NOT NULL,
  `lastupdatedby` varchar(255) NOT NULL,
  PRIMARY KEY (`connection_id`),
  KEY `FK_user_connections_1` (`userid`),
  KEY `FK_user_connections_2` (`friend_id`),
  KEY `FK_user_connections_3` (`statusid`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 AUTO_INCREMENT=1 ;

-- --------------------------------------------------------

--
-- Table structure for table `user_education`
--

CREATE TABLE IF NOT EXISTS `user_education` (
  `education_id` int(11) NOT NULL AUTO_INCREMENT,
  `userid` int(11) NOT NULL,
  `school_name` varchar(255) NOT NULL,
  `degree` varchar(255) NOT NULL,
  `specialization` varchar(255) NOT NULL,
  `education_notes` varchar(255) NOT NULL,
  `from_year` int(4) NOT NULL,
  `from_month` int(2) NOT NULL,
  `to_year` int(4) NOT NULL,
  `to_month` int(2) NOT NULL,
  `createddatetime` datetime NOT NULL,
  `updateddatetime` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `deleteddatetime` datetime NOT NULL,
  `statusid` int(11) NOT NULL,
  `createdby` varchar(255) NOT NULL,
  `lastupdatedby` varchar(255) NOT NULL,
  PRIMARY KEY (`education_id`),
  KEY `FK_user_education_1` (`userid`),
  KEY `FK_user_education_2` (`statusid`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 AUTO_INCREMENT=1 ;

-- --------------------------------------------------------

--
-- Table structure for table `user_experience`
--

CREATE TABLE IF NOT EXISTS `user_experience` (
  `experience_id` int(11) NOT NULL AUTO_INCREMENT,
  `userid` int(11) NOT NULL,
  `company_name` varchar(255) NOT NULL,
  `job_title` varchar(255) NOT NULL,
  `job_location` varchar(255) NOT NULL,
  `from_year` int(4) NOT NULL,
  `from_month` int(2) NOT NULL,
  `to_year` int(4) NOT NULL,
  `to_month` int(2) NOT NULL,
  `present_working` tinyint(1) NOT NULL,
  `company_description` text NOT NULL,
  `country_id` int(11) NOT NULL,
  `state_id` int(11) NOT NULL,
  `createddatetime` datetime NOT NULL,
  `updateddatetime` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `deleteddatetime` datetime NOT NULL,
  `statusid` int(11) NOT NULL,
  `createdby` varchar(255) NOT NULL,
  `lastupdatedby` varchar(255) NOT NULL,
  PRIMARY KEY (`experience_id`),
  KEY `FK_user_experience_1` (`userid`),
  KEY `FK_user_experience_2` (`statusid`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 AUTO_INCREMENT=1 ;

-- --------------------------------------------------------

--
-- Table structure for table `user_images`
--

CREATE TABLE IF NOT EXISTS `user_images` (
  `user_image_id` int(11) NOT NULL AUTO_INCREMENT,
  `userid` int(11) NOT NULL,
  `image_path` varchar(45) NOT NULL,
  `is_primary` tinyint(1) NOT NULL DEFAULT '0',
  `createddatetime` datetime NOT NULL,
  `updateddatetime` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `deleteddatetime` datetime NOT NULL,
  `statusid` int(11) NOT NULL,
  `createdby` varchar(255) NOT NULL,
  `lastupdatedby` varchar(255) NOT NULL,
  PRIMARY KEY (`user_image_id`),
  KEY `FK_user_images_1` (`statusid`),
  KEY `FK_user_images_2` (`userid`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 AUTO_INCREMENT=1 ;

-- --------------------------------------------------------

--
-- Table structure for table `user_profile`
--

CREATE TABLE IF NOT EXISTS `user_profile` (
  `profile_id` int(11) NOT NULL AUTO_INCREMENT,
  `userid` int(11) NOT NULL,
  `display_name` varchar(255) NOT NULL,
  `date_of_birth` date NOT NULL,
  `gender` enum('Male','Female') NOT NULL DEFAULT 'Male',
  `about_us` text NOT NULL,
  `marital_status` enum('Single','Married') NOT NULL DEFAULT 'Single',
  `interests` varchar(255) NOT NULL,
  `timezone_id` int(11) NOT NULL,
  `country_id` int(11) NOT NULL,
  `state_id` int(11) NOT NULL,
  `createddatetime` datetime NOT NULL,
  `updateddatetime` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `deleteddatetime` datetime NOT NULL,
  `statusid` int(11) NOT NULL,
  `createdby` varchar(255) NOT NULL,
  `lastupdatedby` varchar(255) NOT NULL,
  PRIMARY KEY (`profile_id`),
  KEY `FK_user_profile_1` (`userid`),
  KEY `FK_user_profile_2` (`statusid`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 AUTO_INCREMENT=1 ;

-- --------------------------------------------------------

--
-- Table structure for table `user_skills_set`
--

CREATE TABLE IF NOT EXISTS `user_skills_set` (
  `user_skills_set_id` int(11) NOT NULL AUTO_INCREMENT,
  `userid` int(11) NOT NULL,
  `course_id` int(11) NOT NULL,
  `from_year` int(4) NOT NULL,
  `from_month` int(2) NOT NULL,
  `to_year` int(4) NOT NULL,
  `to_month` int(2) NOT NULL,
  `createddatetime` datetime NOT NULL,
  `updateddatetime` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `deleteddatetime` datetime NOT NULL,
  `statusid` int(11) NOT NULL,
  `createdby` varchar(255) NOT NULL,
  `lastupdatedby` varchar(255) NOT NULL,
  PRIMARY KEY (`user_skills_set_id`),
  KEY `FK_user_skills_set_1` (`userid`),
  KEY `FK_user_skills_set_2` (`statusid`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 AUTO_INCREMENT=1 ;

-- --------------------------------------------------------

--
-- Table structure for table `user_z_email_address`
--

CREATE TABLE IF NOT EXISTS `user_z_email_address` (
  `user_email_address_id` int(11) NOT NULL AUTO_INCREMENT,
  `userid` int(11) NOT NULL,
  `email_address` varchar(255) NOT NULL,
  `email_type` enum('Personal','Work','Other') NOT NULL,
  `createddatetime` datetime NOT NULL,
  `updateddatetime` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `deleteddatetime` datetime NOT NULL,
  `statusid` int(11) NOT NULL,
  `createdby` varchar(255) NOT NULL,
  `lastupdatedby` varchar(255) NOT NULL,
  PRIMARY KEY (`user_email_address_id`),
  KEY `FK_user_email_address_1` (`userid`),
  KEY `FK_user_email_address_2` (`statusid`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 AUTO_INCREMENT=1 ;

-- --------------------------------------------------------

--
-- Table structure for table `user_z_ims`
--

CREATE TABLE IF NOT EXISTS `user_z_ims` (
  `user_ims_id` int(11) NOT NULL AUTO_INCREMENT,
  `userid` int(11) NOT NULL,
  `network_type` enum('Skype','Gtalk','Other') NOT NULL,
  `ims_screen_name` varchar(255) NOT NULL,
  `is_primary` tinyint(1) NOT NULL DEFAULT '0',
  `createddatetime` datetime NOT NULL,
  `updateddatetime` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `deleteddatetime` datetime NOT NULL,
  `statusid` int(11) NOT NULL,
  `createdby` varchar(255) NOT NULL,
  `lastupdatedby` varchar(255) NOT NULL,
  PRIMARY KEY (`user_ims_id`),
  KEY `FK_user_ims_1` (`statusid`),
  KEY `FK_user_ims_2` (`userid`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 AUTO_INCREMENT=1 ;

-- --------------------------------------------------------

--
-- Table structure for table `user_z_phones`
--

CREATE TABLE IF NOT EXISTS `user_z_phones` (
  `user_phone_id` int(11) NOT NULL AUTO_INCREMENT,
  `userid` int(11) NOT NULL,
  `phone_prefix` varchar(45) NOT NULL,
  `phone_number` varchar(45) NOT NULL,
  `phone_type` enum('Personal','Home','Office','Other') NOT NULL,
  `is_primary` tinyint(1) NOT NULL DEFAULT '0',
  `createddatetime` datetime NOT NULL,
  `updateddatetime` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `deleteddatetime` datetime NOT NULL,
  `statusid` int(11) NOT NULL,
  `createdby` varchar(255) NOT NULL,
  `lastupdatedby` varchar(255) NOT NULL,
  PRIMARY KEY (`user_phone_id`),
  KEY `FK_user_phones_1` (`userid`),
  KEY `FK_user_phones_2` (`statusid`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 AUTO_INCREMENT=1 ;

-- --------------------------------------------------------

--
-- Table structure for table `user_z_social_media`
--

CREATE TABLE IF NOT EXISTS `user_z_social_media` (
  `user_social_media_id` int(11) NOT NULL AUTO_INCREMENT,
  `social_media_url` varchar(255) NOT NULL,
  `social_media_types_id` int(11) NOT NULL,
  `createddatetime` datetime NOT NULL,
  `updateddatetime` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `deleteddatetime` datetime NOT NULL,
  `statusid` int(11) NOT NULL,
  `createdby` varchar(255) NOT NULL,
  `lastupdatedby` varchar(255) NOT NULL,
  PRIMARY KEY (`user_social_media_id`),
  KEY `FK_user_social_media_1` (`social_media_types_id`),
  KEY `FK_user_social_media_2` (`statusid`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 AUTO_INCREMENT=1 ;

-- --------------------------------------------------------

--
-- Table structure for table `user_z_social_media_types`
--

CREATE TABLE IF NOT EXISTS `user_z_social_media_types` (
  `social_media_types_id` int(11) NOT NULL AUTO_INCREMENT,
  `social_media_title` varchar(45) NOT NULL,
  `createddatetime` datetime NOT NULL,
  `updateddatetime` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `deleteddatetime` datetime NOT NULL,
  `statusid` int(11) NOT NULL,
  `createdby` varchar(255) NOT NULL,
  `lastupdatedby` varchar(255) NOT NULL,
  PRIMARY KEY (`social_media_types_id`),
  KEY `FK_user_social_media_types_1` (`statusid`)
) ENGINE=InnoDB  DEFAULT CHARSET=latin1 AUTO_INCREMENT=6 ;

--
-- Dumping data for table `user_z_social_media_types`
--

INSERT INTO `user_z_social_media_types` (`social_media_types_id`, `social_media_title`, `createddatetime`, `updateddatetime`, `deleteddatetime`, `statusid`, `createdby`, `lastupdatedby`) VALUES
(1, 'Facebook', '0000-00-00 00:00:00', '2013-05-16 13:05:19', '0000-00-00 00:00:00', 1, '', ''),
(2, 'Twitter', '0000-00-00 00:00:00', '2013-05-16 13:05:19', '0000-00-00 00:00:00', 1, '', ''),
(3, 'Flickr', '0000-00-00 00:00:00', '2013-05-16 13:05:19', '0000-00-00 00:00:00', 1, '', ''),
(4, 'Linkedin', '0000-00-00 00:00:00', '2013-05-16 13:05:19', '0000-00-00 00:00:00', 1, '', ''),
(5, 'Youtube', '0000-00-00 00:00:00', '2013-05-16 13:05:19', '0000-00-00 00:00:00', 1, '', '');

-- --------------------------------------------------------

--
-- Table structure for table `user_z_websites`
--

CREATE TABLE IF NOT EXISTS `user_z_websites` (
  `user_website_id` int(11) NOT NULL AUTO_INCREMENT,
  `userid` int(11) NOT NULL,
  `website_type` enum('Website','Blog','Other') NOT NULL,
  `website_url` varchar(255) NOT NULL,
  `is_primary` tinyint(1) NOT NULL DEFAULT '0',
  `createddatetime` datetime NOT NULL,
  `updateddatetime` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `deleteddatetime` datetime NOT NULL,
  `statusid` int(11) NOT NULL,
  `createdby` varchar(255) NOT NULL,
  `lastupdatedby` varchar(255) NOT NULL,
  PRIMARY KEY (`user_website_id`),
  KEY `FK_user_websites_1` (`userid`),
  KEY `FK_user_websites_2` (`statusid`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 AUTO_INCREMENT=1 ;

-- --------------------------------------------------------

--
-- Table structure for table `z_apmmastersecurityquestions`
--

CREATE TABLE IF NOT EXISTS `z_apmmastersecurityquestions` (
  `securityquestionid` int(11) NOT NULL AUTO_INCREMENT COMMENT 'primary key for security questions',
  `securityquestion` varchar(200) NOT NULL COMMENT 'security question',
  `createddatetime` datetime NOT NULL COMMENT 'record created date time',
  `updateddatetime` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'record updated date time',
  `deleteddatetime` datetime DEFAULT NULL COMMENT 'record deleted date time',
  `statusid` int(11) NOT NULL COMMENT 'record status as a foreign key from apmmasterrecordsstate table',
  `createdby` varchar(255) DEFAULT NULL COMMENT 'Stores MySQL User Created Details',
  `lastupdatedby` varchar(255) DEFAULT NULL COMMENT 'Stores MySQL User last updated Details',
  PRIMARY KEY (`securityquestionid`),
  UNIQUE KEY `UQ_securityquestion` (`securityquestion`),
  KEY `FK_apmmastersecurityquestions_statusid_apmmasterrecordsstate` (`statusid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='security questions are entered here' AUTO_INCREMENT=1 ;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `apmemailtemplate`
--
ALTER TABLE `apmemailtemplate`
  ADD CONSTRAINT `FK_apmemailtemplate_statusid_apmmasterrecordstate` FOREIGN KEY (`statusid`) REFERENCES `apmmasterrecordsstate` (`statusid`);

--
-- Constraints for table `apmmailqueue`
--
ALTER TABLE `apmmailqueue`
  ADD CONSTRAINT `FK_apmmailqueue_mailstatus_apmmastermailstatus` FOREIGN KEY (`mailstatus`) REFERENCES `apmmastermailstatus` (`mailstatusid`),
  ADD CONSTRAINT `FK_apmmailqueue_statusid_apmmasterrecordsstate` FOREIGN KEY (`statusid`) REFERENCES `apmmasterrecordsstate` (`statusid`);

--
-- Constraints for table `apmmailqueuelog`
--
ALTER TABLE `apmmailqueuelog`
  ADD CONSTRAINT `FK_apmemailqueuelog_statusid_apmmasterrecordstate` FOREIGN KEY (`statusid`) REFERENCES `apmmasterrecordsstate` (`statusid`),
  ADD CONSTRAINT `FK_apmmailqueuelog_mailqueueid` FOREIGN KEY (`mailqueueid`) REFERENCES `apmmailqueue` (`mailqueueid`);

--
-- Constraints for table `apmmasteractions`
--
ALTER TABLE `apmmasteractions`
  ADD CONSTRAINT `FK_apmmasteractions_controllerid_apmmastercontrollers` FOREIGN KEY (`controllerid`) REFERENCES `apmmastercontrollers` (`controllerid`),
  ADD CONSTRAINT `FK_apmmasteractions_statusid_apmmasterrecordsstate` FOREIGN KEY (`statusid`) REFERENCES `apmmasterrecordsstate` (`statusid`);

--
-- Constraints for table `apmmastercontrollers`
--
ALTER TABLE `apmmastercontrollers`
  ADD CONSTRAINT `FK_apmmastercontrollers_moduleid_apmmastermodules` FOREIGN KEY (`moduleid`) REFERENCES `apmmastermodules` (`moduleid`),
  ADD CONSTRAINT `FK_apmmastercontrollers_statusid_apmmasterrecordsstate` FOREIGN KEY (`statusid`) REFERENCES `apmmasterrecordsstate` (`statusid`);

--
-- Constraints for table `apmmastermodules`
--
ALTER TABLE `apmmastermodules`
  ADD CONSTRAINT `FK_apmmastermodules_statusid_apmmasterrecordsstate` FOREIGN KEY (`statusid`) REFERENCES `apmmasterrecordsstate` (`statusid`);

--
-- Constraints for table `apmmasterroleprivileges`
--
ALTER TABLE `apmmasterroleprivileges`
  ADD CONSTRAINT `FK_apmmasterroleprivileges_actionid_apmmasteractions` FOREIGN KEY (`actionid`) REFERENCES `apmmasteractions` (`actionid`),
  ADD CONSTRAINT `FK_apmmasterroleprivileges_roleid_apmmasterroles` FOREIGN KEY (`roleid`) REFERENCES `apmmasterroles` (`roleid`),
  ADD CONSTRAINT `FK_apmmasterroleprivileges_statusid_apmmasterrecordsstate` FOREIGN KEY (`statusid`) REFERENCES `apmmasterrecordsstate` (`statusid`);

--
-- Constraints for table `apmmasterroles`
--
ALTER TABLE `apmmasterroles`
  ADD CONSTRAINT `FK_apmmasterroles_statusid_apmmasterrecordsstate` FOREIGN KEY (`statusid`) REFERENCES `apmmasterrecordsstate` (`statusid`);

--
-- Constraints for table `apmmasteruseractions`
--
ALTER TABLE `apmmasteruseractions`
  ADD CONSTRAINT `FK_apmuseractions_statusid_apmmasterrecordsstate` FOREIGN KEY (`statusid`) REFERENCES `apmmasterrecordsstate` (`statusid`);

--
-- Constraints for table `apmpasswordhistory`
--
ALTER TABLE `apmpasswordhistory`
  ADD CONSTRAINT `FK_apmpasswordhistory_statusid_apmmasterrecordsstate` FOREIGN KEY (`statusid`) REFERENCES `apmmasterrecordsstate` (`statusid`),
  ADD CONSTRAINT `FK_apmpasswordhistory_userid_apmusers` FOREIGN KEY (`userid`) REFERENCES `apmusers` (`userid`);

--
-- Constraints for table `apmsecurityqa`
--
ALTER TABLE `apmsecurityqa`
  ADD CONSTRAINT `FK_apmsecurityqa_userid_apmusers` FOREIGN KEY (`userid`) REFERENCES `apmusers` (`userid`),
  ADD CONSTRAINT `FK_apmsecurityquestionanswers_statusid_apmmasterrecordsstate` FOREIGN KEY (`statusid`) REFERENCES `apmmasterrecordsstate` (`statusid`);

--
-- Constraints for table `apmuseractivitylog`
--
ALTER TABLE `apmuseractivitylog`
  ADD CONSTRAINT `FK_apmuseractivitylog_actionid_apmmasteractions` FOREIGN KEY (`actionid`) REFERENCES `apmmasteractions` (`actionid`),
  ADD CONSTRAINT `FK_apmuseractivitylog_statusid_apmmasterrecordsstate` FOREIGN KEY (`statusid`) REFERENCES `apmmasterrecordsstate` (`statusid`),
  ADD CONSTRAINT `FK_apmuseractivitylog_useractionid_apmmasteruseractions` FOREIGN KEY (`useractionid`) REFERENCES `apmmasteruseractions` (`useractionid`),
  ADD CONSTRAINT `FK_apmuseractivitylog_userid_apmusers` FOREIGN KEY (`userid`) REFERENCES `apmusers` (`userid`);

--
-- Constraints for table `apmuserrolemapping`
--
ALTER TABLE `apmuserrolemapping`
  ADD CONSTRAINT `FK_apmuserrolemapping_roleid_apmmasterroles` FOREIGN KEY (`roleid`) REFERENCES `apmmasterroles` (`roleid`),
  ADD CONSTRAINT `FK_apmuserrolemapping_statusid_apmmasterrecordsstate` FOREIGN KEY (`statusid`) REFERENCES `apmmasterrecordsstate` (`statusid`),
  ADD CONSTRAINT `FK_apmuserrolemapping_userid_apmusers` FOREIGN KEY (`userid`) REFERENCES `apmusers` (`userid`);

--
-- Constraints for table `apmusers`
--
ALTER TABLE `apmusers`
  ADD CONSTRAINT `FK_apmusers_statusid_apmmasterrecordsstate` FOREIGN KEY (`statusid`) REFERENCES `apmmasterrecordsstate` (`statusid`);

--
-- Constraints for table `com_country`
--
ALTER TABLE `com_country`
  ADD CONSTRAINT `FK_com_country_1` FOREIGN KEY (`statusid`) REFERENCES `apmmasterrecordsstate` (`statusid`);

--
-- Constraints for table `com_meta_data`
--
ALTER TABLE `com_meta_data`
  ADD CONSTRAINT `FK_store_meta_data_1` FOREIGN KEY (`statusid`) REFERENCES `apmmasterrecordsstate` (`statusid`);

--
-- Constraints for table `social_album`
--
ALTER TABLE `social_album`
  ADD CONSTRAINT `FK_social_album_1` FOREIGN KEY (`statusid`) REFERENCES `apmmasterrecordsstate` (`statusid`),
  ADD CONSTRAINT `FK_social_album_2` FOREIGN KEY (`album_type_id`) REFERENCES `social_album_types` (`album_type_id`);

--
-- Constraints for table `social_album_files`
--
ALTER TABLE `social_album_files`
  ADD CONSTRAINT `FK_social_photos_1` FOREIGN KEY (`statusid`) REFERENCES `apmmasterrecordsstate` (`statusid`),
  ADD CONSTRAINT `FK_social_photos_2` FOREIGN KEY (`userid`) REFERENCES `apmusers` (`userid`),
  ADD CONSTRAINT `FK_social_photos_3` FOREIGN KEY (`album_id`) REFERENCES `social_album` (`album_id`);

--
-- Constraints for table `social_album_files_comments`
--
ALTER TABLE `social_album_files_comments`
  ADD CONSTRAINT `FK_social_album_files_comments_3` FOREIGN KEY (`file_id`) REFERENCES `social_album_files` (`file_id`),
  ADD CONSTRAINT `FK_social_album_photos_comments_2` FOREIGN KEY (`userid`) REFERENCES `apmusers` (`userid`),
  ADD CONSTRAINT `FK_social_album_photos_comments_3` FOREIGN KEY (`statusid`) REFERENCES `apmmasterrecordsstate` (`statusid`);

--
-- Constraints for table `social_album_types`
--
ALTER TABLE `social_album_types`
  ADD CONSTRAINT `FK_social_album_types_1` FOREIGN KEY (`statusid`) REFERENCES `apmmasterrecordsstate` (`statusid`);

--
-- Constraints for table `social_blog_articles`
--
ALTER TABLE `social_blog_articles`
  ADD CONSTRAINT `FK_social_blog_articles_1` FOREIGN KEY (`blog_category_id`) REFERENCES `social_blog_categories` (`blog_category_id`),
  ADD CONSTRAINT `FK_social_blog_articles_2` FOREIGN KEY (`statusid`) REFERENCES `apmmasterrecordsstate` (`statusid`),
  ADD CONSTRAINT `FK_social_blog_articles_3` FOREIGN KEY (`userid`) REFERENCES `apmusers` (`userid`);

--
-- Constraints for table `social_blog_articles_comments`
--
ALTER TABLE `social_blog_articles_comments`
  ADD CONSTRAINT `FK_social_blog_articles_comments_1` FOREIGN KEY (`blog_article_id`) REFERENCES `social_blog_articles` (`blog_article_id`),
  ADD CONSTRAINT `FK_social_blog_articles_comments_2` FOREIGN KEY (`userid`) REFERENCES `apmusers` (`userid`),
  ADD CONSTRAINT `FK_social_blog_articles_comments_3` FOREIGN KEY (`statusid`) REFERENCES `apmmasterrecordsstate` (`statusid`);

--
-- Constraints for table `social_events`
--
ALTER TABLE `social_events`
  ADD CONSTRAINT `FK_social_events_1` FOREIGN KEY (`statusid`) REFERENCES `apmmasterrecordsstate` (`statusid`),
  ADD CONSTRAINT `FK_social_events_2` FOREIGN KEY (`userid`) REFERENCES `apmusers` (`userid`);

--
-- Constraints for table `social_groups`
--
ALTER TABLE `social_groups`
  ADD CONSTRAINT `FK_social_groups_1` FOREIGN KEY (`statusid`) REFERENCES `apmmasterrecordsstate` (`statusid`);

--
-- Constraints for table `social_groups_comments`
--
ALTER TABLE `social_groups_comments`
  ADD CONSTRAINT `FK_social_groups_comments_1` FOREIGN KEY (`group_id`) REFERENCES `social_groups` (`group_id`),
  ADD CONSTRAINT `FK_social_groups_comments_2` FOREIGN KEY (`userid`) REFERENCES `apmusers` (`userid`),
  ADD CONSTRAINT `FK_social_groups_comments_3` FOREIGN KEY (`statusid`) REFERENCES `apmmasterrecordsstate` (`statusid`);

--
-- Constraints for table `social_groups_posts`
--
ALTER TABLE `social_groups_posts`
  ADD CONSTRAINT `FK_social_groups_posts_1` FOREIGN KEY (`group_id`) REFERENCES `social_groups` (`group_id`),
  ADD CONSTRAINT `FK_social_groups_posts_2` FOREIGN KEY (`userid`) REFERENCES `apmusers` (`userid`),
  ADD CONSTRAINT `FK_social_groups_posts_3` FOREIGN KEY (`statusid`) REFERENCES `apmmasterrecordsstate` (`statusid`);

--
-- Constraints for table `social_groups_users`
--
ALTER TABLE `social_groups_users`
  ADD CONSTRAINT `FK_social_groups_users_1` FOREIGN KEY (`group_id`) REFERENCES `social_groups` (`group_id`),
  ADD CONSTRAINT `FK_social_groups_users_2` FOREIGN KEY (`userid`) REFERENCES `apmusers` (`userid`),
  ADD CONSTRAINT `FK_social_groups_users_3` FOREIGN KEY (`statusid`) REFERENCES `apmmasterrecordsstate` (`statusid`);

--
-- Constraints for table `social_internal_messaging`
--
ALTER TABLE `social_internal_messaging`
  ADD CONSTRAINT `FK_social_internal_messaging_1` FOREIGN KEY (`statusid`) REFERENCES `apmmasterrecordsstate` (`statusid`),
  ADD CONSTRAINT `FK_social_internal_messaging_2` FOREIGN KEY (`userid`) REFERENCES `apmusers` (`userid`);

--
-- Constraints for table `store_categories`
--
ALTER TABLE `store_categories`
  ADD CONSTRAINT `FK_store_categories_1` FOREIGN KEY (`statusid`) REFERENCES `apmmasterrecordsstate` (`statusid`);

--
-- Constraints for table `store_categories_images`
--
ALTER TABLE `store_categories_images`
  ADD CONSTRAINT `FK_store_categories_images_1` FOREIGN KEY (`category_id`) REFERENCES `store_categories` (`category_id`),
  ADD CONSTRAINT `FK_store_categories_images_2` FOREIGN KEY (`statusid`) REFERENCES `apmmasterrecordsstate` (`statusid`);

--
-- Constraints for table `store_merchants`
--
ALTER TABLE `store_merchants`
  ADD CONSTRAINT `FK_store_merchants_1` FOREIGN KEY (`statusid`) REFERENCES `apmmasterrecordsstate` (`statusid`);

--
-- Constraints for table `store_merchants_images`
--
ALTER TABLE `store_merchants_images`
  ADD CONSTRAINT `FK_store_merchants_images_1` FOREIGN KEY (`merchant_id`) REFERENCES `store_merchants` (`merchant_id`),
  ADD CONSTRAINT `FK_store_merchants_images_2` FOREIGN KEY (`statusid`) REFERENCES `apmmasterrecordsstate` (`statusid`);

--
-- Constraints for table `store_merchants_users`
--
ALTER TABLE `store_merchants_users`
  ADD CONSTRAINT `FK_store_merchants_users_1` FOREIGN KEY (`merchant_id`) REFERENCES `store_merchants` (`merchant_id`),
  ADD CONSTRAINT `FK_store_merchants_users_2` FOREIGN KEY (`userid`) REFERENCES `apmusers` (`userid`),
  ADD CONSTRAINT `FK_store_merchants_users_3` FOREIGN KEY (`statusid`) REFERENCES `apmmasterrecordsstate` (`statusid`);

--
-- Constraints for table `store_products`
--
ALTER TABLE `store_products`
  ADD CONSTRAINT `FK_store_products_1` FOREIGN KEY (`statusid`) REFERENCES `apmmasterrecordsstate` (`statusid`),
  ADD CONSTRAINT `FK_store_products_2` FOREIGN KEY (`attributes_group_id`) REFERENCES `store_products_attributes_groups` (`attributes_group_id`);

--
-- Constraints for table `store_products_attributes`
--
ALTER TABLE `store_products_attributes`
  ADD CONSTRAINT `FK_store_products_attributes_1` FOREIGN KEY (`statusid`) REFERENCES `apmmasterrecordsstate` (`statusid`);

--
-- Constraints for table `store_products_attributes_groups`
--
ALTER TABLE `store_products_attributes_groups`
  ADD CONSTRAINT `FK_store_products_attributes_groups_1` FOREIGN KEY (`statusid`) REFERENCES `apmmasterrecordsstate` (`statusid`);

--
-- Constraints for table `store_products_attributes_sets`
--
ALTER TABLE `store_products_attributes_sets`
  ADD CONSTRAINT `FK_store_products_attributes_sets_1` FOREIGN KEY (`statusid`) REFERENCES `apmmasterrecordsstate` (`statusid`),
  ADD CONSTRAINT `FK_store_products_attributes_sets_2` FOREIGN KEY (`attributes_group_id`) REFERENCES `store_products_attributes_groups` (`attributes_group_id`);

--
-- Constraints for table `store_products_attributes_sets_mapping`
--
ALTER TABLE `store_products_attributes_sets_mapping`
  ADD CONSTRAINT `FK_store_products_attributes_sets_mapping_1` FOREIGN KEY (`attribute_id`) REFERENCES `store_products_attributes` (`attribute_id`),
  ADD CONSTRAINT `FK_store_products_attributes_sets_mapping_2` FOREIGN KEY (`attributes_set_id`) REFERENCES `store_products_attributes_sets` (`attributes_set_id`),
  ADD CONSTRAINT `FK_store_products_attributes_sets_mapping_3` FOREIGN KEY (`statusid`) REFERENCES `apmmasterrecordsstate` (`statusid`);

--
-- Constraints for table `store_products_attributes_values`
--
ALTER TABLE `store_products_attributes_values`
  ADD CONSTRAINT `FK_store_products_attributes_values_1` FOREIGN KEY (`attribute_id`) REFERENCES `store_products_attributes` (`attribute_id`),
  ADD CONSTRAINT `FK_store_products_attributes_values_2` FOREIGN KEY (`product_id`) REFERENCES `store_products` (`product_id`),
  ADD CONSTRAINT `FK_store_products_attributes_values_3` FOREIGN KEY (`statusid`) REFERENCES `apmmasterrecordsstate` (`statusid`);

--
-- Constraints for table `store_products_categories`
--
ALTER TABLE `store_products_categories`
  ADD CONSTRAINT `FK_store_products_categories_1` FOREIGN KEY (`product_id`) REFERENCES `store_products` (`product_id`),
  ADD CONSTRAINT `FK_store_products_categories_2` FOREIGN KEY (`category_id`) REFERENCES `store_categories` (`category_id`),
  ADD CONSTRAINT `FK_store_products_categories_3` FOREIGN KEY (`statusid`) REFERENCES `apmmasterrecordsstate` (`statusid`);

--
-- Constraints for table `store_products_description`
--
ALTER TABLE `store_products_description`
  ADD CONSTRAINT `FK_store_products_description_1` FOREIGN KEY (`product_id`) REFERENCES `store_products` (`product_id`),
  ADD CONSTRAINT `FK_store_products_description_2` FOREIGN KEY (`statusid`) REFERENCES `apmmasterrecordsstate` (`statusid`);

--
-- Constraints for table `store_products_images`
--
ALTER TABLE `store_products_images`
  ADD CONSTRAINT `FK_store_products_images_1` FOREIGN KEY (`product_id`) REFERENCES `store_products` (`product_id`),
  ADD CONSTRAINT `FK_store_products_images_2` FOREIGN KEY (`statusid`) REFERENCES `apmmasterrecordsstate` (`statusid`);

--
-- Constraints for table `store_products_price`
--
ALTER TABLE `store_products_price`
  ADD CONSTRAINT `FK_store_products_price_1` FOREIGN KEY (`product_id`) REFERENCES `store_products` (`product_id`),
  ADD CONSTRAINT `FK_store_products_price_2` FOREIGN KEY (`statusid`) REFERENCES `apmmasterrecordsstate` (`statusid`);

--
-- Constraints for table `store_products_reviews`
--
ALTER TABLE `store_products_reviews`
  ADD CONSTRAINT `FK_store_products_reviews_1` FOREIGN KEY (`product_id`) REFERENCES `store_products` (`product_id`),
  ADD CONSTRAINT `FK_store_products_reviews_2` FOREIGN KEY (`statusid`) REFERENCES `apmmasterrecordsstate` (`statusid`);

--
-- Constraints for table `store_users_invoices`
--
ALTER TABLE `store_users_invoices`
  ADD CONSTRAINT `FK_store_users_invoices_1` FOREIGN KEY (`invoices_shipping_status_id`) REFERENCES `store_users_invoices_master_shipping_status` (`invoices_shipping_status_id`),
  ADD CONSTRAINT `FK_store_users_invoices_2` FOREIGN KEY (`invoices_payment_status_id`) REFERENCES `store_users_invoices_master_payment_status` (`invoices_payment_status_id`),
  ADD CONSTRAINT `FK_store_users_invoices_3` FOREIGN KEY (`statusid`) REFERENCES `apmmasterrecordsstate` (`statusid`),
  ADD CONSTRAINT `FK_store_users_invoices_4` FOREIGN KEY (`userid`) REFERENCES `apmusers` (`userid`);

--
-- Constraints for table `store_users_invoices_billing_and_shipping_details`
--
ALTER TABLE `store_users_invoices_billing_and_shipping_details`
  ADD CONSTRAINT `FK_store_users_invoices_billing_and_shipping_details_1` FOREIGN KEY (`invoice_id`) REFERENCES `store_users_invoices` (`invoice_id`),
  ADD CONSTRAINT `FK_store_users_invoices_billing_and_shipping_details_2` FOREIGN KEY (`statusid`) REFERENCES `apmmasterrecordsstate` (`statusid`);

--
-- Constraints for table `store_users_invoices_details`
--
ALTER TABLE `store_users_invoices_details`
  ADD CONSTRAINT `FK_store_users_invoices_details_1` FOREIGN KEY (`product_id`) REFERENCES `store_products` (`product_id`),
  ADD CONSTRAINT `FK_store_users_invoices_details_2` FOREIGN KEY (`invoice_id`) REFERENCES `store_users_invoices` (`invoice_id`),
  ADD CONSTRAINT `FK_store_users_invoices_details_3` FOREIGN KEY (`statusid`) REFERENCES `apmmasterrecordsstate` (`statusid`);

--
-- Constraints for table `store_users_invoices_master_payment_status`
--
ALTER TABLE `store_users_invoices_master_payment_status`
  ADD CONSTRAINT `FK_store_users_invoices_master_payment_status_1` FOREIGN KEY (`statusid`) REFERENCES `apmmasterrecordsstate` (`statusid`);

--
-- Constraints for table `store_users_invoices_master_shipping_status`
--
ALTER TABLE `store_users_invoices_master_shipping_status`
  ADD CONSTRAINT `FK_store_users_invoices_master_shipping_status_1` FOREIGN KEY (`statusid`) REFERENCES `apmmasterrecordsstate` (`statusid`);

--
-- Constraints for table `store_users_temp_cart`
--
ALTER TABLE `store_users_temp_cart`
  ADD CONSTRAINT `FK_store_users_temp_cart_1` FOREIGN KEY (`product_id`) REFERENCES `store_products` (`product_id`),
  ADD CONSTRAINT `FK_store_users_temp_cart_2` FOREIGN KEY (`statusid`) REFERENCES `apmmasterrecordsstate` (`statusid`),
  ADD CONSTRAINT `FK_store_users_temp_cart_3` FOREIGN KEY (`userid`) REFERENCES `apmusers` (`userid`);

--
-- Constraints for table `user_address`
--
ALTER TABLE `user_address`
  ADD CONSTRAINT `FK_user_address_1` FOREIGN KEY (`userid`) REFERENCES `apmusers` (`userid`),
  ADD CONSTRAINT `FK_user_address_2` FOREIGN KEY (`statusid`) REFERENCES `apmmasterrecordsstate` (`statusid`);

--
-- Constraints for table `user_connections`
--
ALTER TABLE `user_connections`
  ADD CONSTRAINT `FK_user_connections_1` FOREIGN KEY (`userid`) REFERENCES `apmusers` (`userid`),
  ADD CONSTRAINT `FK_user_connections_2` FOREIGN KEY (`friend_id`) REFERENCES `apmusers` (`userid`),
  ADD CONSTRAINT `FK_user_connections_3` FOREIGN KEY (`statusid`) REFERENCES `apmmasterrecordsstate` (`statusid`);

--
-- Constraints for table `user_education`
--
ALTER TABLE `user_education`
  ADD CONSTRAINT `FK_user_education_1` FOREIGN KEY (`userid`) REFERENCES `apmusers` (`userid`),
  ADD CONSTRAINT `FK_user_education_2` FOREIGN KEY (`statusid`) REFERENCES `apmmasterrecordsstate` (`statusid`);

--
-- Constraints for table `user_experience`
--
ALTER TABLE `user_experience`
  ADD CONSTRAINT `FK_user_experience_1` FOREIGN KEY (`userid`) REFERENCES `apmusers` (`userid`),
  ADD CONSTRAINT `FK_user_experience_2` FOREIGN KEY (`statusid`) REFERENCES `apmmasterrecordsstate` (`statusid`);

--
-- Constraints for table `user_images`
--
ALTER TABLE `user_images`
  ADD CONSTRAINT `FK_user_images_1` FOREIGN KEY (`statusid`) REFERENCES `apmmasterrecordsstate` (`statusid`),
  ADD CONSTRAINT `FK_user_images_2` FOREIGN KEY (`userid`) REFERENCES `apmusers` (`userid`);

--
-- Constraints for table `user_profile`
--
ALTER TABLE `user_profile`
  ADD CONSTRAINT `FK_user_profile_1` FOREIGN KEY (`userid`) REFERENCES `apmusers` (`userid`),
  ADD CONSTRAINT `FK_user_profile_2` FOREIGN KEY (`statusid`) REFERENCES `apmmasterrecordsstate` (`statusid`);

--
-- Constraints for table `user_skills_set`
--
ALTER TABLE `user_skills_set`
  ADD CONSTRAINT `FK_user_skills_set_1` FOREIGN KEY (`userid`) REFERENCES `apmusers` (`userid`),
  ADD CONSTRAINT `FK_user_skills_set_2` FOREIGN KEY (`statusid`) REFERENCES `apmmasterrecordsstate` (`statusid`);

--
-- Constraints for table `user_z_email_address`
--
ALTER TABLE `user_z_email_address`
  ADD CONSTRAINT `FK_user_email_address_1` FOREIGN KEY (`userid`) REFERENCES `apmusers` (`userid`),
  ADD CONSTRAINT `FK_user_email_address_2` FOREIGN KEY (`statusid`) REFERENCES `apmmasterrecordsstate` (`statusid`);

--
-- Constraints for table `user_z_ims`
--
ALTER TABLE `user_z_ims`
  ADD CONSTRAINT `FK_user_ims_1` FOREIGN KEY (`statusid`) REFERENCES `apmmasterrecordsstate` (`statusid`),
  ADD CONSTRAINT `FK_user_ims_2` FOREIGN KEY (`userid`) REFERENCES `apmusers` (`userid`);

--
-- Constraints for table `user_z_phones`
--
ALTER TABLE `user_z_phones`
  ADD CONSTRAINT `FK_user_phones_1` FOREIGN KEY (`userid`) REFERENCES `apmusers` (`userid`),
  ADD CONSTRAINT `FK_user_phones_2` FOREIGN KEY (`statusid`) REFERENCES `apmmasterrecordsstate` (`statusid`);

--
-- Constraints for table `user_z_social_media`
--
ALTER TABLE `user_z_social_media`
  ADD CONSTRAINT `FK_user_social_media_1` FOREIGN KEY (`social_media_types_id`) REFERENCES `user_z_social_media_types` (`social_media_types_id`),
  ADD CONSTRAINT `FK_user_social_media_2` FOREIGN KEY (`statusid`) REFERENCES `apmmasterrecordsstate` (`statusid`);

--
-- Constraints for table `user_z_social_media_types`
--
ALTER TABLE `user_z_social_media_types`
  ADD CONSTRAINT `FK_user_social_media_types_1` FOREIGN KEY (`statusid`) REFERENCES `apmmasterrecordsstate` (`statusid`);

--
-- Constraints for table `user_z_websites`
--
ALTER TABLE `user_z_websites`
  ADD CONSTRAINT `FK_user_websites_1` FOREIGN KEY (`userid`) REFERENCES `apmusers` (`userid`),
  ADD CONSTRAINT `FK_user_websites_2` FOREIGN KEY (`statusid`) REFERENCES `apmmasterrecordsstate` (`statusid`);

--
-- Constraints for table `z_apmmastersecurityquestions`
--
ALTER TABLE `z_apmmastersecurityquestions`
  ADD CONSTRAINT `FK_apmmastersecurityquestions_statusid_apmmasterrecordsstate` FOREIGN KEY (`statusid`) REFERENCES `apmmasterrecordsstate` (`statusid`);

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
