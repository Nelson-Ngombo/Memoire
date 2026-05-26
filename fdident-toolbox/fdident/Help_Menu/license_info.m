% Frequency Domain System Identification Toolbox
%      Software License Agreement
% 
%      This software, the Frequency Domain System Identification Toolbox 
%      for MATLAB(r) (the "Program"), which contains now a graphical user 
%      interface and data/model object handling is being licensed for 
%      use with MATLAB.
%      MATLAB is a registered trademark of The MathWorks, Inc.
% 
%      Conditions (liability, etc.) are listed below. 
% 
%      GENERAL TERMS 
% 
%      LICENSE GRANT. By accepting the registration, X2 Consulting, Inc. grants 
%      to Licensee a nonexclusive license to install and use the 
%      Program(s) as provided by the installation procedure. The 
%      licensed Program is, and shall at all times remain, the property 
%      of the copyright holders and/or its licensors, and Licensee shall 
%      have no right, title, or interest therein, except as expressly 
%      set forth in this Agreement.
% 
%      INSTALLATION AND USE. By accepting the terms and conditions of 
%      the Agreement, Licensee accepts the applicable rights and agrees 
%      to be bound by the applicable obligations and restrictions of the 
%      License Option purchased. 
% 
%      License Options. 
%      Individual License. The Program may be installed and operated on 
%      a single designated computer. 
% 
%      Group License. The Program may be installed and operated on a 
%      designated number of computers (up to the number of Group Copies 
%      purchased). Licensee shall accurately administer, count, and 
%      control the number of copies of each licensed Program installed. 
% 
%      Concurrent License. The Program may be installed on a single 
%      network server, and, where appropriate, portions of the Program 
%      on individual computers to accelerate startup times, so long as 
%      the installations on the individual computers are controlled by 
%      the license manager on the single network server. Licensee may 
%      have as many sessions of a Program in use at any given time as 
%      the number of Concurrent Copies purchased. 
% 
%      Classroom License. Program licensed to degree-granting 
%      educational institutions at X2Con Classroom License discount are 
%      restricted to use in connection with on-campus computing 
%      facilities that are used solely in support of classroom 
%      instruction of students. The right to use the Program for any 
%      other purposes, including commercial purposes, is expressly 
%      prohibited. 
% 
%      Student License (Student versions of the Program or any Program 
%      licensed at a student discount). Student Licenses are restricted 
%      to use on the student's own computer. Student Licenses are 
%      further restricted to use in connection with courses offered by 
%      degree-granting institutions, either by students working toward a 
%      degree, or by continuing education students. The right to use the 
%      Program for any other purposes, including commercial purposes, is 
%      expressly prohibited. Notwithstanding anything to the contrary 
%      contained in this Agreement, Student Licenses are 
%      nontransferable. Maintenance and Support are not provided with 
%      the Student License. 
% 
%      Installation and rights
%      The Program may be installed on a backup computer (while the 
%      designated computer is disabled) or on a replacement computer. 
%      Replacements include both permanent and temporary use at the same 
%      or different site. Temporary use at a different site may include 
%      installation for use at home by Licensee's employees, provided 
%      Licensee permits such home use and Licensee otherwise complies 
%      with the terms of this Agreement and causes its employees to so 
%      comply, including full compliance with all applicable laws and 
%      regulations relating to import and export of technical data and 
%      computer software. 
% 
%      Licensee may not sell, license, sublicense, rent, or make the 
%      Program available for use by any Third Parties. 
% 
%      Licensee shall not provide access to the Program via a Web 
%      application without procuring specific rights to do so.
% 
%      Licensees of the Concurrent License option are prohibited from 
%      providing Program access to users located outside the country in 
%      which the license manager server is installed. 
% 
%      Licensee shall not provide multi-user access to the Program by 
%      calling the Program as a server from other program without 
%      procuring specific rights to do so.
% 
%      Licensee may make backup copies of the Program as necessary to 
%      support the use of the Program in accordance with this Agreement. 
%      Licensee may not remove any copyright, trademark, proprietary 
%      rights, disclaimer or warning notice included on or embedded in 
%      any part of the Program. All copies of Program shall contain all 
%      copyright and proprietary notices as in the original.
% 
%      Licensee shall not attempt to access or use Program that Licensee 
%      is not currently licensed to use. 
% 
%      Special conditions by geographical area
% 
%      EUROPEAN UNION: Except as expressly provided by this Agreement, 
%      Licensee may not alter or modify the Program without the consent 
%      of the copyright holders. In particular, Licensee may not alter, 
%      adapt, translate, or convert 'M-files' or 'P-code' contained in 
%      the Program in order to use those files with any products other 
%      than products of The MathWorks, nor may the Licensee incorporate 
%      or use 'M-files', 'P-code' or any other part of the Program in or 
%      as part of another computer program. 
%      All copies of the Program and Documentation, whether made by 
%      Licensee or otherwise, shall be subject to the terms of this 
%      Agreement. 
%      Licensee shall take appropriate action by instruction, agreement, 
%      or otherwise with any persons permitted access to the Program, so 
%      as to enable Licensee to satisfy its obligations under the terms 
%      of this Agreement.
% 
%      FEDERAL ACQUISITION: This provision applies to all acquisitions 
%      of the Program and Documentation by or for the federal government 
%      of the United States. By accepting delivery of the Program, the 
%      government hereby agrees that this software qualifies as 
%      'commercial' computer software within the meaning of FAR Part 
%      12.212, DFARS Part 227.7202-1, DFARS Part 227.7202-3, DFARS Part 
%      252.227-7013, and DFARS Part 252.227-7014. The terms and 
%      conditions of this Agreement shall pertain to the government's 
%      use and disclosure of the Program and Documentation, and shall 
%      supersede any conflicting contractual terms or conditions. If 
%      this license fails to meet the government's minimum needs or is 
%      inconsistent in any respect with federal procurement law, the 
%      government agrees to return the Program and Documentation, 
%      unused, to X2 Consulting, Inc. 
% 
%      Conditions
% 
%      LIMITED WARRANTY/LIMITATION OF REMEDIES. X2 Consulting, Inc. warrants 
%      that X2 Consulting, or its licensors has the right to grant the license 
%      rights hereunder. X2 Consulting warrants that the downloadable file on 
%      the server will be free of errors, or it will be replaced by 
%      X2 Consulting upon notification from the Licensee. X2 Consulting further 
%      warrants, for a period of one (1) year from delivery, that each 
%      copy of each Program will conform in all material respects to the 
%      description of such Program's operation. In the event that the 
%      Program does not operate as warranted, Licensee's exclusive 
%      remedy and X2 Consulting sole liability under this warranty shall be a) 
%      the correction or workaround by X2 Consulting of major defects within a 
%      reasonable time, or b) should such correction or workaround prove 
%      neither satisfactory nor practical, termination of the relevant 
%      license and refund of the purchase fee paid to X2 Consulting for the 
%      Program. All requests for warranty assistance should be directed 
%      to X2 Consulting, Inc., Budapest, Hungary. 
%      EXCEPT AS EXPRESSLY PROVIDED BY THIS AGREEMENT (OR AS IMPLIED BY 
%      LAW WHERE THE LAW PROVIDES THAT THE PARTICULAR TERMS IMPLIED 
%      CANNOT BE EXCLUDED BY CONTRACT), ALL OTHER CONDITIONS, 
%      WARRANTIES, OR OTHER TERMS (INCLUDING ANY WITH REGARD TO 
%      INFRINGEMENT, MERCHANTABLE QUALITY, OR FITNESS FOR PURPOSE) ARE 
%      EXCLUDED. SOME STATES DO NOT ALLOW LIMITATIONS ON HOW LONG AN 
%      IMPLIED WARRANTY LASTS, SO THE ABOVE LIMITATION MAY NOT APPLY TO 
%      LICENSEE. THIS WARRANTY GIVES LICENSEE SPECIFIC LEGAL RIGHTS AND 
%      LICENSEE MAY ALSO HAVE OTHER RIGHTS WHICH VARY FROM STATE TO 
%      STATE. LICENSEE ACCEPTS RESPONSIBILITY FOR ITS USE OF THE PROGRAM 
%      AND THE RESULTS OBTAINED THEREFROM. 
% 
%      LIMITATION OF LIABILITY. THE PROGRAM SHOULD NOT BE RELIED ON AS 
%      THE SOLE BASIS TO SOLVE A PROBLEM WHOSE INCORRECT SOLUTION COULD 
%      RESULT IN INJURY TO PERSON OR PROPERTY. IF A PROGRAM IS EMPLOYED 
%      IN SUCH A MANNER, IT IS AT THE LICENSEE'S OWN RISK AND X2 CONSULTING 
%      EXPLICITLY DISCLAIMS ALL LIABILITY FOR SUCH MISUSE TO THE EXTENT 
%      ALLOWED BY LAW. X2 CONSULTING'S LIABILITY FOR DEATH OR PERSONAL INJURY 
%      RESULTING FROM NEGLIGENCE OR FOR ANY OTHER MATTER IN RELATION TO 
%      WHICH LIABILITY BY LAW CANNOT BE EXCLUDED OR LIMITED SHALL NOT BE 
%      EXCLUDED OR LIMITED. EXCEPT AS AFORESAID, (A) ANY OTHER LIABILITY 
%      OF X2 CONSULTING (WHETHER IN RELATION TO BREACH OF CONTRACT, NEGLIGENCE 
%      OR OTHERWISE) SHALL NOT IN TOTAL EXCEED THE AMOUNT PAID TO X2 CONSULTING 
%      UNDER THIS AGREEMENT IN THE TWELVE MONTH PERIOD PRECEDING THE 
%      CLAIM IN QUESTION, FOR THE PROGRAM WITH RESPECT TO WHICH THE 
%      LIABILITY IN QUESTION ARISES, AS INSTALLED ON THE DESIGNATED 
%      COMPUTER(S) OR DESIGNATED SERVER(S) FOR WHICH USE OF THE PROGRAM 
%      IS LICENSED HEREUNDER; AND (B) X2 CONSULTING SHALL HAVE NO LIABILITY FOR 
%      ANY INDIRECT OR CONSEQUENTIAL LOSS (WHETHER FORESEEABLE OR 
%      OTHERWISE AND INCLUDING LOSS OF PROFITS, LOSS OF BUSINESS, LOSS 
%      OF OPPORTUNITY, AND LOSS OF USE OF ANY COMPUTER HARDWARE OR 
%      SOFTWARE). SOME STATES DO NOT ALLOW THE EXCLUSION OR LIMITATION 
%      OF INCIDENTAL OR CONSEQUENTIAL DAMAGES, SO THE ABOVE EXCLUSION OR 
%      LIMITATION MAY NOT APPLY TO LICENSEE. 
% 
%      MAINTENANCE AND SUPPORT. If the Licensee is registered, X2 Consulting, 
%      Inc. shall, through the developers: deliver subsequent releases 
%      of the Program that are not charged for separately; exert 
%      reasonable efforts to both (a) provide, within a reasonable time, 
%      workarounds for any material programming errors in the current 
%      release of the Program that are directly attributable to the 
%      developers, and (b) correct such errors in the next available 
%      release, provided Licensee provides the developers with 
%      sufficient information to identify the problems. During this same 
%      term, Licensee shall also be entitled to receive technical 
%      support by telephone, fax or electronic mail regarding the 
%      installation and/or use of the Licensed Program and their 
%      interaction with hardware, operating environments, and other 
%      software products. X2 Consulting, Inc. reserves the option to 
%      discontinue, in whole or in part, offering maintenance and 
%      support. In such a case, Licensees registered no earlier than 6 
%      months before discontinuing maintenance and support, may request 
%      refund of the purchase price. 
% 
%      TERM. This Agreement shall continue until the earlier of (a) 
%      termination by X2 Consulting, Inc. or Licensee as provided below, or (b) 
%      such time as there are no Program being licensed to Licensee 
%      hereunder. 
% 
%      For Student Licenses: The Student License term extends only for 
%      the duration of Licensee's enrollment in a degree-granting 
%      institution or participation in a continuing education program of 
%      a degree-granting institution. 
% 
%      ACCEPTANCE PERIOD. Licensee may receive a full refund if within 
%      thirty (30) days from the date of delivery (the 'acceptance 
%      period') licensee does not accept the terms and conditions of 
%      this license and the applicable addendum, or if licensee 
%      terminates this license for any reason, within the acceptance 
%      period. 
% 
%      DOCUMENTATION.  The user guides and instructional material, if 
%      any, accompanying delivery of a Program as may be updated from 
%      time to time.  Documentation may be delivered in hard copy and/or 
%      electronic format.
% 
%      TERMINATION. X2 Consulting, Inc. may terminate this license grant, by 
%      written notice to Licensee if Licensee breaches any material term 
%      of this license, including failure to pay any purchase price due, 
%      and Licensee has not cured such breach within sixty (60) days of 
%      written notification. Licensee may terminate this license at any 
%      time, for any reason. Licensee shall not be entitled to any 
%      refund if this license is terminated, except for purchase prices 
%      paid for any Program for which the Acceptance Period has not 
%      expired at the time of termination. Upon termination, Licensee 
%      shall promptly return all but archival copies of the Program and 
%      Documentation in Licensee's possession or control, or promptly 
%      provide written certification of their destruction. 
% 
%      TAXES, DUTIES, CUSTOMS. Absent appropriate exemption 
%      certificate(s), Licensee shall pay all taxes, duties, or customs, 
%      except for taxes based on X2 Consulting net income. 
% 
%      ASSIGNMENT. This license is nontransferable to a Third Party 
%      without X2 Consulting consent, which shall not be unreasonably withheld. 
%      This license may be transferred to an Affiliate provided that 
%      X2 Consulting is notified in writing of the transfer and the Affiliate 
%      accepts these same terms and conditions. 
% 
%      GENERAL. To the extent any law, treaty, or regulation is in 
%      conflict with this Agreement, the conflicting terms of this 
%      Agreement shall be superseded only to the extent necessary by 
%      such law, treaty, or regulation. If any provision of this 
%      Agreement shall be otherwise unlawful, void, or otherwise 
%      unenforceable, that provision shall be enforced to the maximum 
%      extent permissible. In either case, the remainder of this 
%      Agreement shall not be affected. The parties agree that the U.N. 
%      Convention on Contracts for the International Sale of Goods shall 
%      not apply to this Agreement. This Agreement contains the entire 
%      understanding of the parties and may not be modified or amended 
%      except by written instrument, executed by authorized 
%      representatives of X2 Consulting and Licensee.